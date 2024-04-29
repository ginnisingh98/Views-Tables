--------------------------------------------------------
--  DDL for Package CSD_MIGRATE_FROM_115X_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIGRATE_FROM_115X_PKG3" AUTHID CURRENT_USER as
/* $Header: csdmig3s.pls 115.12 2004/04/01 01:17:57 vparvath noship $ */


/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_ACT_HDR_MIG3                                       */
/* description   : procedure for migrating ACTUALS Headers data                  */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_act_hdr_mig3(p_slab_number IN NUMBER DEFAULT 1);

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_CHARGE_ESTIMATE_LINES_MIG3                                */
/* description   : procedure for migrating ESTIMATES data                        */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_charge_estimate_lines_mig3(p_slab_number IN NUMBER DEFAULT 1);


/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_ESTIMATE_LINES_MIG3                                */
/* description   : procedure for migrating ESTIMATES data                        */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_estimate_lines_mig3(p_slab_number IN NUMBER DEFAULT 1);

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_ACTTOEST_CHARGE_LINE_MIG3                                 */
/* description   : procedure for copying the ACTUAL CHARGE LINE TO ESTIMATE      */
/*                 CHARGE LINE : creates new Estimate charge line                */
/*                 1. linking the new Estimate charge line to Depot Estimate line*/
/*             and 2. create a new Depot Actual line and link it old Estimate    */
/*                    charge line for CSD_REPAIR_ESTIMATE_LINES table data       */
/*                    migration from 11.5.9 to 11.5.10                           */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_acttoest_charge_line_mig3(p_slab_number IN NUMBER DEFAULT 1);

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_JOB_XREF_MIG3                                      */
/* description   : procedure for migrating CSD_REPAIR_JOB_XREF table data        */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_job_xref_mig3(p_slab_number IN NUMBER DEFAULT 1);



/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_TYPE_MIG3                                           */
/* description   : procedure for migrating repair_type_ref table data            */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/* Repair Types. - In the 11.5.10, we will changed the repair type ref for       */
/* the seeeded repair type - "Walk-In Repair" to  "Repair and Return",           */
/* and the repair type ref for the seed repair type -                            */
/* "Walk-In Repair with Loaner" to "Loaner, Repair and Return".                  */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_type_mig3;


/*-------------------------------------------------------------------------------*/
/* procedure name: csd_cost_data_mig3                                            */
/* description   : procedure for migrating item_cost information from CSD_reapir_Estimate_lines  table data        */
/*                 from 11.5.9 to 11.5.10                                        */
/* modified : sangigup Mar 8th, 2004                                             */
/*                                                                               */
/*-------------------------------------------------------------------------------*/
  PROCEDURE csd_cost_Data_mig3(p_slab_number IN NUMBER) ;

/*-------------------------------------------------------------------------------*/
/* procedure name: LOG_ERROR                                                     */
/* description   : procedure for logging errors while migrating                  */
/*                 csd_repair_estimate_lines table cost data                     */
/*                 from 11.5.9 to 11.5.10                                        */
/* created         sangigup Mar 8, 2004                                          */
/* This procedure will log the item_cost in CSD_UPG_ERRORS table                 */
/*-------------------------------------------------------------------------------*/
   procedure log_Error( p_estimate_line_id number,p_item_cost number, p_cost_currency_code varchar2);

    /*------------------------------------------------------------------------*/
    /* procedure name: CSD_REPAIR_HISTORY_MIG3                                */
    /* description   : procedure for migrating CSD_REPAIR_HISTORY table data  */
    /*                 from 11.5.9 to 11.5.10                                 */
    /* Created : vkjain on SEPT-30-2003                                       */
    /*                                                                        */
    /* Here are the details for the migration -                               */
    /* Event Code (New field(s) populated)      Comments
    /* RR         Receiving Org Name (paramc3)  Using receiving transactions
    /*                                          Id to determine values.
    /*
    /* RSC        Receiving Subinv Name(paramc1)Using receiving transactions
    /*                                          Id to determine values.
    /*
    /* JS         <None>                        Job Name, Item Name,
    /*                                          Quantity allocated, Group Id
    /*                                          and Concurrent Request Number
    /*                                          fields not populated  unable
    /*                                          to determine values.
    /*                                          The event code will be
    /*                                          renamed to JSU.
    /*
    /* TC         Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* TOC        Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* TSC        Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* PS         Shipping Org Name (paramc3),  Using delivery detail Id
    /*            Shipping SubinvName (paramc4) to determine values.
    /*
    /* A          <None>                        Event Code renamed to ESU.
    /*                                          Estimate total field not
    /*                                          populated unable to
    /*                                          determine value.
    /*
    /* R          <None>                        Event Code renamed to ESU.
    /*                                          Estimate total field not
    /*                                          populated unable to
    /*                                          determine value.
    /*
    /* Points to note
    /*
    /* 1. New events do not need data migration effort.
    /* 2. JC is the only event that exists in 11.5.9 and has new fields for
    /*    11.5.10 but does not appear in the list above. This is because we are
    /*    unable to determine the value for the new field 'Quantity Allocated'.
    /* 3. As a pre-upgrade step, we expect the users to fully complete all the
    /*    pending wip jobs and run the update program.
    /*                                                                        */
    /*                                                                        */
    /*------------------------------------------------------------------------*/

    PROCEDURE csd_repair_history_mig3(p_slab_number IN NUMBER);


    /*------------------------------------------------------------------------*/
    /* procedure name: CSD_PRODUCT_TRANS_MIG3(p_slab_Number Number)
    /* description   : procedure for migrating CSD_PRODUCT_TRANSACTIONS data  */
    /*                 from 11.5.9 to 11.5.10                                 */
    /* Created : saupadhy SEPT-30-2003                                       */
    /*                                                                        */
    /* Here are the details for the migration -                               */
    /* Prod Txn Status  (New field(s) populated)      Comments
    /* RECEIVED         Quantity_Received,                                   */
    /*                  source_serial_number                                 */
    /*                  source_instance_id                                   */
    /*                  sub_inventory                                        */
    /*                  lot_Number                                           */
    /*                  locator_id                                           */
    /* SHIPPED          Quantity_Shipped                                     */
    /*                  source_serial_number                                 */
    /*                  source_instance_id                                   */
    /*                  non_source_serial_number                             */
    /*                  non_source_instance_id                               */
    /*                  sub_inventory                                        */
    /*                  lot_Number                                           */
    /*                  locator_id                                           */
    /* BOOKED     action_type is 'RMA' and order line qty is > 1             */
    /*            Only qty that is captured in csd_repair_history is         */
    /*            updated in csd_product_txns table                          */
    /*RELEASED   action_type is 'SHIP' and order line qty is > 1             */
    /*           Only qty that is captured in csd_repair_history is          */
    /*           updated in csd_product_txns table.                          */
    /************************************************************************/
    procedure CSD_PRODUCT_TRANS_MIG3(p_slab_Number Number) ;

END CSD_Migrate_From_115X_PKG3;

 

/
