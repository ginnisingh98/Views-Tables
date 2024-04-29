--------------------------------------------------------
--  DDL for Package Body MTL_INTERCOMPANY_INVOICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_INTERCOMPANY_INVOICES" as
/* $Header: INVICIVB.pls 120.2 2006/03/29 05:41:10 sbitra noship $ */

function get_transfer_price (I_transaction_id in  number,
                             I_price_list_id  in  number,
                             I_sell_ou_id     in  number,
                             I_ship_ou_id     in  number,
                             O_currency_code  out NOCOPY varchar2,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
			     I_order_line_id  IN  NUMBER default null)
         return number
is
   --Bug 5118727 Added new parameter I_order_line_id to get_transfer_price

--  This function can be replaced by custom code to establish the
--  transfer price used in intercompany invoicing.  When this
--  function returns NULL, the transfer pricing algorithm in the base
--  application code will be used to establish the transfer price.
--
--  Otherwise, the returned number coupled with the returned currency
--  in O_currency_code will be used as the transfer price.

begin
    O_currency_code  := null;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;

    return(NULL);

exception
when others then
    raise;
end get_transfer_price;

procedure callback (I_event                in varchar2,
                    I_transaction_id       in number,
                    I_report_header_id     in number,
                    I_customer_trx_line_id in number)
is

--  This procedure defines various callbacks in the intercompany
--  invoicing programs which can be replaced with custom code to
--  provide addition and modification to the existing invoice creation
--  logic.
--
--  Valid events are:
--
--  RA_INTERFACE_LINES -
--    after an insert into RA_INTERFACE_LINES in the AR invoice
--    creation program.  The transaction_id can be used to identify
--    the row in RA_INTERFACE_LINES using the transaction flex column
--    INTERFACE_LINE_ATTRIBUTE7.
--
--  AP_EXPENSE_REPORT_HEADERS -
--    after the insert into AP_EXPENSE_REPORT_HEADERS in the AP
--    invoice creation program.  The report_header_id should be used
--    to identify the row inserted.
--
--  AP_EXPENSE_REPORT_LINES -
--    after the insert into AP_EXPENSE_REPORT_LINES in the AP invoice
--    creation program.  The report_header_id along with
--    customer_trx_line_id, which is mapped to reference_1 column,
--    should be used to identify the row.

begin
    if (I_event = 'RA_INTERFACE_LINES') then
        null;
    elsif (I_event = 'AP_EXPENSE_REPORT_HEADERS') then
        null;
    elsif (I_event = 'AP_EXPENSE_REPORT_LINES') then
        null;
    end if;

exception
when others then
    raise;
end callback;

end MTL_INTERCOMPANY_INVOICES;

/
