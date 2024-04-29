--------------------------------------------------------
--  DDL for Package POR_IFT_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_IFT_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: PORIFTS.pls 120.0 2005/06/04 00:39:55 appldev noship $ */

/******************************************************************
 * Concatenate all attribute codes and values into a text value   *
 * for an associate Requisition Line.                             *
 ******************************************************************/
PROCEDURE get_attach_text(
                p_requisition_line_id 	IN NUMBER,
		p_preparer_language     IN VARCHAR2,
                p_to_supplier_text      OUT NOCOPY LONG,
    		p_to_supplier_name      OUT NOCOPY VARCHAR2,
    		p_to_buyer_text         OUT NOCOPY LONG,
    		p_to_buyer_name         OUT NOCOPY VARCHAR2);

/******************************************************************
 * Gets Requisition Lines that have associated info template data *
 ******************************************************************/
PROCEDURE add_info_template_attachment(
                p_req_header_id     IN NUMBER,
    		p_category_id       IN NUMBER DEFAULT 33,
                p_preparer_language IN VARCHAR2);

END por_ift_info_pkg;

 

/
