--------------------------------------------------------
--  DDL for Package PAY_US_SOE_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SOE_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: pyussoeu.pkh 115.0 99/09/08 06:35:20 porting ship    $  */

/***************************************************************************
*  Copyright (c)1999 Oracle Corporation, Redwood Shores, California, USA   *
*                          All rights reserved.                            *
****************************************************************************
*                                                                          *
* File:  pyussoeu.pkh                                                      *
*                                                                          *
* Description:                                                             *
*                                                                          *
*                                                                          *
*                                                                          *
* History                                                                  *
* -----------------------------------------------------                    *
* 26-JUN-1999         pganguly        Created                              *
*                                                                          *
*                                                                          *
***************************************************************************/

function get_base_sal ( p_assignment_action_id in number)
return number;

pragma restrict_references(get_base_sal, wnds);
pragma restrict_references(get_base_sal, wnps);

end pay_us_soe_utils_pkg;

 

/
