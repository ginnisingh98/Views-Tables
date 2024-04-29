--------------------------------------------------------
--  DDL for Package ARP_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECEIVABLE_APPLICATIONS" AUTHID CURRENT_USER AS
/* $Header: ARPLAPPS.pls 115.3 2002/11/15 02:38:37 anukumar ship $ */

--
    PROCEDURE PopulateCashReceiptHistoryId( p_CashReceiptId         IN     NUMBER,
                                            p_CashReceiptHistoryId  IN OUT NOCOPY NUMBER );
END;

 

/
