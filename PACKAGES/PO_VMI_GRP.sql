--------------------------------------------------------
--  DDL for Package PO_VMI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VMI_GRP" AUTHID CURRENT_USER as
--$Header: POXGVMIS.pls 115.4 2002/11/23 03:29:20 sbull noship $

--===============+============================================================+
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--============================================================================+
--|                                                                           |
--|  FILENAME :            POXGVMIS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This package contains the function that return TRUE|
--|                        if there exist a VMI ASL within the Operating Unit |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   exist_vmi_asl                                      |
--|                                                                           |
--|  HISTORY:              26-FEB-2002 : fdubois - Empty Stubb created        |
--|                        13-MAR-2002 : fdubois - Modified dbdrv command     |
--|                        15-APR-2002 : Fdubois - Added function for Global  |
--|                                      VMI ASL validation                   |
--|===========================================================================+


/*===========================================================================
  FUNCTION NAME:	exist_vmi_asl

  DESCRIPTION:		the function retunrs TRUE if there exist a VMI ASL
                        within the Operating Unit. If there are none it
                        returns FALSE

  PARAMETERS:		In:

			RETURN: TRUE if exists VMI ASL

  DESIGN REFERENCES:	APXSSFSO_VMI_DLD.doc


  CHANGE HISTORY:	Created		26-FEB-02	FDUBOIS
===========================================================================*/
FUNCTION  exist_vmi_asl RETURN BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	validate_global_vmi_asl

  DESCRIPTION:		the function retunrs TRUE if the Global ASL can be
                        VMI for the IN parameters (define the ASL). False
                        otherwize. It then also return the Validation Error
                        Message name

  PARAMETERS:		In: INVENTORY_ITEM_ID      :Item identifier
                            SUPPLIER_SITE_ID       : supplier site identifier

			Out:VALIDATION_ERROR_NAME  : Error message name

                        Return: TRUE if OK to have Global VMI ASL

  DESIGN REFERENCES:	MGD_VMI_ASL_DLD.rtf


  CHANGE HISTORY:	Created		15-APR-02	FDUBOIS
===========================================================================*/
FUNCTION  validate_global_vmi_asl  ( x_inventory_item_id       IN   number ,
                                     x_supplier_site_id        IN   number ,
                                     x_validation_error_name   OUT NOCOPY  varchar2 )

RETURN BOOLEAN;


END PO_VMI_GRP;

 

/
