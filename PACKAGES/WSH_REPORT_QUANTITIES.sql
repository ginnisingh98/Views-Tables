--------------------------------------------------------
--  DDL for Package WSH_REPORT_QUANTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_REPORT_QUANTITIES" AUTHID CURRENT_USER AS
/* $Header: WSHUTRQS.pls 115.4 99/07/16 08:24:13 porting ship $ */

-- NAME: populate_temp_table
-- DESC: populated the temporary table with all the lines and their shipped
--       quantity this commits the records on creation
-- ARGS: report_id  = must be a unique id, usual the request id of a conc prog.
--       p_mode     = either PAK ir INV. calculates extra values if in one of
--                    these.
--       p_departure_id
--       p_delivery_id
--       p_order_line
--       p_asn      = will limit the Ship Qty to to this asn or greater
--       p_upd_ship = Update shipping flag: use this to reflect whether
--                    you want the sq to be calculated only if update shipping
--                    has run. Therefore if 'Y' then it will return zero if
--                    update shipping has not run otherwise it return the
--                    SC quantity.
--       p_debug    = Flag to turn debugging information ON  or OFF
--
PROCEDURE populate_temp_table (p_report_id in number,
                               p_mode in varchar2 default NULL,
                               p_departure_id in number default NULL,
                               p_delivery_id in number default NULL,
                               p_order_line in number default NULL,
                               p_asn in number default NULL,
                               p_upd_ship in varchar2 default 'N',
                               p_debug in varchar2 default 'OFF');
-- NAME: lines_shipped_quantity
-- DESC: returns the shipped quantity for a particular so_line in the
--       given asn and there after
--       this rollbacks all rows it created in the temp table at end.
-- ARGS:  p_order_line = so_lines.line_id
--        p_item_id    = item_id
--        p_asn        = asn sequence number
--        p_upd_ship = Update shipping flag: use this to reflect whether
--                     you want the sq to be calculated only if update shipping
--                     has run. Therefore if 'Y' then it will return zero if
--                     update shipping has not run otherwise it return the
--                     SC quantity.
--        p_debug    = Flag to turn debugging information ON  or OFF
--
--
--
FUNCTION  line_shipped_quantity (p_order_line in number,
                                 p_item_id in number,
                                 p_asn in number,
                                 p_upd_ship in varchar2 default 'N',
                                 p_debug in varchar2 default 'OFF') RETURN NUMBER;

-- NAME: delete_report
-- DESC: deletes records for this report from the temp table.
--       also deletes any older than 2 days that are still in the table.
Procedure delete_report        (p_report_id in number);


-- INTERNAL PROCEDURES
--=====================
-- NAME: insert_order_line
-- DESC: inserts the order line into the temporary table.
procedure insert_order_line (p_report_id    in number,
                             p_departure_id in number,
                             p_delivery_id  in number,
                             p_line_id      in number,
                             p_mode in varchar2 default NULL,  -- BUG 787126
                             p_debug in varchar2 default 'OFF');

-- BUG : 787126 : Created a procedure to print the BOM for ATO MODELS
-- NAME: insert_ato_components
-- DESC: inserts the components for ATO Model.
procedure insert_ato_components (p_report_id    in number,
                             p_departure_id in number,
                             p_delivery_id  in number,
                             p_line_id      in number,
                             p_mode in varchar2 default NULL,
                             p_debug in varchar2 default 'OFF');
-- BUG 787126 : End

-- NAME: add_non_ship_lines
-- DESC: adds non shippable lines to the temp table.
Procedure add_non_ship_lines   (p_report_id in number,
                                p_debug in varchar2 default 'OFF');
Procedure set_shipped_quantity (p_report_id in number,
                                p_debug in varchar2 default 'OFF');
Procedure set_invoice_quantity (p_report_id in number,
                                p_debug in varchar2 default 'OFF');
end WSH_REPORT_QUANTITIES;

 

/
