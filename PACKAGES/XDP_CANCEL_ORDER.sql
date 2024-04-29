--------------------------------------------------------
--  DDL for Package XDP_CANCEL_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_CANCEL_ORDER" AUTHID CURRENT_USER AS
/* $Header: XDPPCNLS.pls 115.0 2003/10/06 12:06:38 appldev noship $ */

PROCEDURE CANCEL_SFM_ORDER
(
    p_application_id                    in NUMBER,
    p_entity_short_name                 in VARCHAR2,
    p_validation_entity_short_name      in VARCHAR2,
    p_validation_tmplt_short_name       in VARCHAR2,
    p_record_set_short_name             in VARCHAR2,
    p_scope                             in VARCHAR2,
    x_result                            out NOCOPY NUMBER
);


END XDP_CANCEL_ORDER;

 

/
