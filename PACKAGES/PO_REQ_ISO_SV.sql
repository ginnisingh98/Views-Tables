--------------------------------------------------------
--  DDL for Package PO_REQ_ISO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_ISO_SV" AUTHID CURRENT_USER AS
/* $Header: POXISOCS.pls 120.0 2005/06/01 18:39:51 appldev noship $ */

PROCEDURE Call_Process_Order(x_oe_header_id   IN  NUMBER,
                             x_oe_line_id     IN  NUMBER,
                             x_oe_line_qty    IN  NUMBER,
                             x_cancel_reason IN VARCHAR2,
                             x_msg_data    OUT NOCOPY VARCHAR2,
                             x_msg_count   OUT NOCOPY NUMBER,
                             l_return_status    OUT NOCOPY  VARCHAR2);

FUNCTION get_return_code(x_status IN varchar2) return VARCHAR2;

END PO_REQ_ISO_SV ;

 

/
