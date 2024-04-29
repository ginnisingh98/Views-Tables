--------------------------------------------------------
--  DDL for Package PO_TAX_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TAX_SV" AUTHID CURRENT_USER as
/* $Header: POXPTAXS.pls 115.5 2003/08/29 22:28:13 zxzhang ship $ */

/*===========================================================================
  PACKAGE NAME:         PO_TAX_SV
  DESCRIPTION:          Contains tax calculation
  CLIENT/SERVER:        Server
  LIBRARY NAME          None
  OWNER:                xkan
  PROCEDURE NAMES:      get_tax(varchar2, number) return number
===========================================================================*/

/* Get already calculated tax from distribution tables */
FUNCTION get_tax(x_calling_form	IN VARCHAR2,
		x_distribution_id	IN NUMBER) RETURN NUMBER;

--pragma restrict_references(get_tax, WNDS, WNPS, RNPS);


-- <FPJ Retroactive Price>
Procedure Get_All_PO_Tax(
                     p_api_version             IN         NUMBER,
                     p_distribution_id         IN         NUMBER,
                     x_recoverable_tax         OUT NOCOPY NUMBER,
                     x_non_recoverable_tax     OUT NOCOPY NUMBER,
                     x_old_recoverable_tax     OUT NOCOPY NUMBER,
                     x_old_non_recoverable_tax OUT NOCOPY NUMBER,
                     x_return_status           OUT NOCOPY VARCHAR2,
                     x_msg_data                OUT NOCOPY VARCHAR2);
END po_tax_sv;

 

/
