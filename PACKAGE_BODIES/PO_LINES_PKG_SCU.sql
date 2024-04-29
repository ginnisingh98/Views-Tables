--------------------------------------------------------
--  DDL for Package Body PO_LINES_PKG_SCU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_PKG_SCU" as
/* $Header: POXPIL5B.pls 115.6 2002/11/26 23:36:59 sbull ship $ */

 procedure check_unique(X_rowid		      VARCHAR2,
			X_line_num	      NUMBER,
                        X_po_header_id        NUMBER
		       ) is

  X_Progress  varchar2(3) := '';
  dummy	   NUMBER;
 begin
        X_progress := '010';

        SELECT  1
        INTO    dummy
        FROM    DUAL
        WHERE  not exists (SELECT 'this line num exists already'
                           FROM   po_lines
                           WHERE  po_header_id = X_po_header_id
                           AND    line_num     = X_line_num
                           AND   (rowid       <> X_rowid OR X_rowid is null));
exception
  when no_data_found then
    po_message_s.app_error('PO_PO_ENTER_UNIQUE_LINE_NUM');
  when others then
    po_message_s.sql_error('check_unique',X_progress,sqlcode);
    raise;
end check_unique;

/*===========================================================================

  PROCEDURE NAME:  select_ship_total

===========================================================================*/

 procedure select_ship_total ( X_po_line_id		IN	NUMBER,
			        X_total 		IN OUT NOCOPY  NUMBER,
			        X_total_RTOT_DB		IN OUT NOCOPY  NUMBER) is

 X_progress varchar2(3) := '';

 begin

/* Bug#2400791 : Modified the following select statement, to take into
account of the cancelled quantity also while updating the total_ship_qty
of the lines block */
         X_progress  := '010';

         select nvl(sum(quantity),0) - nvl(sum(quantity_cancelled),0),
                nvl(sum(quantity),0) - nvl(sum(quantity_cancelled),0)
         into   X_total,
                X_total_RTOT_DB
         from   PO_LINE_LOCATIONS PLL
         where  PLL.PO_LINE_ID = X_po_line_id;

 exception

         when no_data_found then
              null;

         when others then
              po_message_s.sql_error('select_ship_total',X_progress,sqlcode);
              raise;

 end select_ship_total;



END PO_LINES_PKG_SCU;

/
