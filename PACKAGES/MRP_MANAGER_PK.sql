--------------------------------------------------------
--  DDL for Package MRP_MANAGER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MANAGER_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPPMGS.pls 115.10 2003/03/04 01:49:09 schaudha ship $ */

    PROCEDURE   compute_sales_order_changes(
                arg_request_id  IN NUMBER,
                arg_user_id     IN NUMBER);

    PROCEDURE   update_sales_orders(
                arg_request_id IN NUMBER,
                arg_user_id IN NUMBER);

    PROCEDURE   create_forecast_items(
                arg_request_id IN NUMBER,
                arg_user_id    IN NUMBER,
                arg_desig      IN VARCHAR2);

    PROCEDURE   explode_in_process(
                arg_in_process_id OUT NOCOPY NUMBER,
                arg_request_id IN NUMBER,
                arg_user_id    IN NUMBER);

    PROCEDURE   mds_explode_in_process(
                arg_in_process_id OUT NOCOPY NUMBER,
                arg_request_id IN NUMBER,
                arg_user_id    IN NUMBER);

    PROCEDURE   update_forecast_desc_flex(
                arg_row_count  IN OUT NOCOPY   NUMBER);

    PROCEDURE   update_schedule_desc_flex(
                arg_row_count  IN OUT NOCOPY   NUMBER,
                arg_schedule_count IN NUMBER,
                arg_forecast_count IN NUMBER,
                arg_so_count       IN NUMBER,
                arg_interorg_count IN NUMBER);

    FUNCTION get_customer_name(
                p_customer_id   IN  NUMBER)RETURN VARCHAR2;

    FUNCTION get_ship_address(
		p_ship_id      	IN NUMBER)RETURN VARCHAR2;

    FUNCTION get_bill_address(
		p_bill_id 	IN NUMBER)RETURN VARCHAR2;

    FUNCTION get_project_id(
		p_demand_id 	IN NUMBER)RETURN NUMBER;

    FUNCTION get_task_id(
		p_demand_id 	IN NUMBER)RETURN NUMBER;

    FUNCTION get_unit_number(
		p_demand_id 	IN NUMBER)RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES(get_customer_name, WNDS, WNPS);
    PRAGMA RESTRICT_REFERENCES(get_ship_address, WNDS, WNPS);
    PRAGMA RESTRICT_REFERENCES(get_bill_address, WNDS, WNPS);
    PRAGMA RESTRICT_REFERENCES(get_project_id, WNDS, WNPS);
    PRAGMA RESTRICT_REFERENCES(get_task_id, WNDS, WNPS);
-- Removed because 8.1.5 does not need this
--    PRAGMA RESTRICT_REFERENCES(get_unit_number, WNDS, WNPS);

    /*------------------------------------------------------------------+
    | Define constants                                                  |
    +------------------------------------------------------------------*/
    var_watch_id            NUMBER;

    VERSION                 CONSTANT CHAR(80) := '$Header: MRPPPMGS.pls 115.10 2003/03/04 01:49:09 schaudha ship $';

    NO_PLANNING             CONSTANT INTEGER := 6;      /* planning */

    ITEM_TYPE_MODEL         CONSTANT INTEGER := 1;      /* BOM Item type */
    ITEM_TYPE_OPTION_CLASS  CONSTANT INTEGER := 2;
    ITEM_TYPE_PLANNING      CONSTANT INTEGER := 3;
    ITEM_TYPE_STANDARD      CONSTANT INTEGER := 4;
    ITEM_TYPE_PRODUCT_FAMILY CONSTANT INTEGER := 5;

    MAGIC_STRING            CONSTANT VARCHAR2(10) := '734jkhJK24';

    SYS_YES                 CONSTANT INTEGER := 1;      /* sys yes no */
    SYS_NO                  CONSTANT INTEGER := 2;

    MTL_SALES_ORDER         CONSTANT INTEGER := 2;      /* sales order */
    MTL_INT_SALES_ORDER     CONSTANT INTEGER := 8;      /* internal sales
                                                           order */

    DO_NOT_PROCESS          CONSTANT INTEGER := 1;
    TO_BE_PROCESSED         CONSTANT INTEGER := 2;      /* process status */
    ALREADY_PROCESSED       CONSTANT INTEGER := 5;
    IN_PROCESS              CONSTANT INTEGER := 3;

    UPDATE_BATCH_SIZE       CONSTANT INTEGER := 100000;

    ATO_NONE                CONSTANT INTEGER := 3;
END mrp_manager_pk;

 

/
