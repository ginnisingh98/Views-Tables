--------------------------------------------------------
--  DDL for Package WIP_DISCRETE_WS_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DISCRETE_WS_MOVE" AUTHID CURRENT_USER AS
/* $Header: wipdsmvs.pls 120.1 2006/09/19 06:30:30 paho noship $ */

  TYPE MoveData IS RECORD
  (
    txnMode        number,
    txnID          number,
    txnType        number,
    orgID          number,
    wipEntityID    number,
    fmOp           number,
    fmStep         number,
    toOp           number,
    toStep         number,
    txnQty         number,
    txnUOM         varchar2(3),
    scrapAcctID    number,
    qaCollectionID number,
    periodID       number,
    assyHeaderID   number,
    compHeaderID   number,
    mtlMode        number
  );


  procedure explodeComponents(p_jobID        in number,
                              p_orgID        in number,
                              p_moveQty      in number,
                              p_fromOp       in number,
                              p_fromStep     in number,
                              p_toOp         in number,
                              p_toStep       in number,
                              p_txnType      in number,
                              x_moveTxnID    out nocopy number,
                              x_cplTxnID     out nocopy number,
                              x_txnHeaderID  out nocopy number,
                              x_compHeaderID out nocopy number,
                              x_batchID      out nocopy number,
                              x_lotEntryType out nocopy number,
                              x_compInfo     out nocopy system.wip_lot_serial_obj_t,
                              x_mtlMode      out nocopy number,
                              x_periodID     out nocopy number,
                              x_returnStatus out nocopy varchar2,
                              x_errMessage   out nocopy varchar2);


  procedure processMove(moveData       in  MoveData,
                        x_returnStatus out nocopy varchar2,
                        x_errMessage   out nocopy varchar2);


  procedure createLocator(p_orgID        in number,
                          p_locatorName  in varchar2,
                          p_subinv       in varchar2,
                          x_locatorID    out nocopy number,
                          x_returnStatus out nocopy varchar2,
                          x_errMessage   out nocopy varchar2);

  procedure checkOvershipment(p_orgID       in number,
                              p_itemID      in number,
                              p_orderLineID in number,
                              p_primaryQty      in number,
                              p_primaryUOM      in varchar2,
                              x_returnStatus out nocopy varchar2,
                              x_errMessage   out nocopy varchar2);



  function clientToServerDate(p_date in date) return date;

  function serverToClientDate(p_date in date) return date;

  procedure initTimezone;

  /* Fix for bug 4568517: New procedure get_prj_loc_lov added.
   *=====================================================================+
   | PROCEDURE
   |   get_prj_loc_lov
   |
   | PURPOSE
   |   A replacement LOV API taken from package INV_UI_ITEM_SUB_LOC_LOVS
   |   for use in WIP. Will be called by LocatorLovService.java to
   |   populate completion locator LOV in discrete workstation.
   |
   |   Returns a REF cursor containing LOV query. For PJM org, the locator
   |   will contain the project number and task number, and will be filtered
   |   on the project and task supplied.
   |
   +=====================================================================*/

  TYPE t_genref IS REF CURSOR;

  PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  );

END wip_discrete_ws_move;

 

/
