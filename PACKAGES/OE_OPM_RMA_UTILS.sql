--------------------------------------------------------
--  DDL for Package OE_OPM_RMA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OPM_RMA_UTILS" AUTHID CURRENT_USER AS
/* $Header: OEXOPMIS.pls 120.0 2005/06/01 00:52:13 appldev noship $ */

--  get_opm_lot_quantities

PROCEDURE get_opm_lot_quantities
(   p_line_id IN NUMBER,
    p_lot_number IN VARCHAR2,
    p_sublot_number IN VARCHAR2,
    p_quantity OUT NOCOPY NUMBER,
    p_quantity2 OUT NOCOPY NUMBER);





END OE_OPM_RMA_UTILS;

 

/
