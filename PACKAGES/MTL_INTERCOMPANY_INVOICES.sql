--------------------------------------------------------
--  DDL for Package MTL_INTERCOMPANY_INVOICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_INTERCOMPANY_INVOICES" AUTHID CURRENT_USER as
/* $Header: INVICIVS.pls 120.3 2006/03/29 05:37:21 sbitra noship $ */


function get_transfer_price (I_transaction_id in  number,
                             I_price_list_id  in  number,
                             I_sell_ou_id     in  number,
                             I_ship_ou_id     in  number,
                             O_currency_code  out NOCOPY varchar2,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
			     I_order_line_id  IN  NUMBER default null	)
         return number;
--Bug 5118727 Added new parameter I_order_line_id to get_transfer_price

procedure callback (I_event                in varchar2,
                    I_transaction_id       in number,
                    I_report_header_id     in number,
                    I_customer_trx_line_id in number);

end MTL_INTERCOMPANY_INVOICES;

 

/
