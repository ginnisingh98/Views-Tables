--------------------------------------------------------
--  DDL for Package CSI_ONT_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ONT_TXN_PUB" AUTHID CURRENT_USER AS
/* $Header: csiponts.pls 120.0.12000000.1 2007/01/16 15:35:24 appldev ship $ */

  PROCEDURE postTransaction(
    p_order_line_id       IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_message_id          OUT NOCOPY NUMBER,
    x_error_code          OUT NOCOPY NUMBER,
    x_error_message       OUT NOCOPY VARCHAR2);

end CSI_ONT_TXN_PUB;

 

/
