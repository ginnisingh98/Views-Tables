--------------------------------------------------------
--  DDL for Package POS_AP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_AP_CHECKS_PKG" AUTHID CURRENT_USER AS
/* $Header: POSAPCKS.pls 120.0 2005/06/01 15:48:10 appldev noship $ */


  PROCEDURE get_po_info(l_check_id IN NUMBER,
    				p_po_switch OUT NOCOPY VARCHAR2,
     				p_po_num OUT NOCOPY VARCHAR2,
     				p_header_id OUT NOCOPY VARCHAR2,
     				p_release_id OUT NOCOPY VARCHAR2);

  PROCEDURE get_invoice_info(l_check_id IN NUMBER,
    				p_invoice_switch OUT NOCOPY VARCHAR2,
     				p_invoice_num OUT NOCOPY VARCHAR2,
     				p_invoice_id OUT NOCOPY VARCHAR2);

END POS_AP_CHECKS_PKG;

 

/
