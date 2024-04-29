--------------------------------------------------------
--  DDL for Package IGIPMSDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPMSDA" AUTHID CURRENT_USER AS
-- $Header: igipmsds.pls 115.8 2002/11/18 13:56:28 panaraya ship $
         PROCEDURE Synchronize_Invoice
            ( p_invoice_id in number ,
                 p_accounting_rule_id in number default null);
         PROCEDURE Synchronize_transfer ( errbuf  out NOCOPY varchar2
                         , retcode out NOCOPY  number
                         , p_transfer_id in number ) ;
         PROCEDURE Synchronize     ( errbuf  out NOCOPY varchar2
                         , retcode out NOCOPY  number
                         , p_mode          in varchar2
                         , p_invoice_num   in varchar2
                         , p_vendor_name   in varchar2
                         , p_batch_name    in varchar2
                        );
END IGIPMSDA;

 

/
