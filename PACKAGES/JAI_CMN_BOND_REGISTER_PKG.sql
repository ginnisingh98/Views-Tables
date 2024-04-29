--------------------------------------------------------
--  DDL for Package JAI_CMN_BOND_REGISTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_BOND_REGISTER_PKG" AUTHID CURRENT_USER as
/* $Header: jai_cmn_bond_reg.pls 120.1 2005/07/20 12:57:04 avallabh ship $ */


/*--------------------------------------------------------------------------------------------------
Change History :

SlNo        Date        Details

1.          22-aug-03   Ssumaith (bug # 3021588) Version 616.1

			This package has been created by sriram. It is to be used for all business validations
       		that require Bond Register information such as bond number , expiry date , register balance

            Get_register_id procedure returns the relevant register id irrespective of whether the register
            is a bond register or not. where ever you need to get the register id based on the parameters,
            should issue a call to this procedure and not use a cursor directly.

            get_register_details procedure returns bond specific details of a passed register id such as
            bond number , validity date , letter of undertaking flag set

			This fix has introduced huge dependency.
			This bug is a prerequisite for all fixes made on this object


2.          12-nov-03   ssumaith  file version 617.1 bug # 3021588

            The length of the comment line was 258 lines,which was causing a problem when mrc program is run.
            all the comment lines and code lines are now ensured to fit within the screen length in
            order to ensure no further error occurs because of this.


3.          08-Jun-2005  Version 116.1 jai_cmn_bond_reg -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.


Future Dependencies For the release Of this Object:-
------------------------------------------------------------------------------------------------------------------------
(Please add a row in the section below only if your bug introduces a dependency due to spec change.
A new call to a object/ A datamodel change )

------------------------------------------------------------------------------------------------------------------------

Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
jai_cmn_bond_register_pkg.sql
------------------------------------------------------------------------------------------------------------------------
616.1                  3021588       IN60104D +                                 ssumaith  22/08/2003   Bond Register Enhancement
                                     2801751   +
                                     2769440



------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------*/

/*
This procedure is used to return the register id and register code applicable for the passed
organization id , location id , order or invoice type id , order or invoice type
*/
procedure get_register_id(p_organization_id        Number ,
                          p_location_id            Number ,
                          p_order_invoice_id       Number ,
                          p_order_invoice_type     varchar2 , -- ( 'Y' means order , 'N' means invoice)
                          p_register_id OUT NOCOPY Number ,
                          p_register_code OUT NOCOPY varchar2);

/*
This procedure returns the bond register balance , register expiry date and whether the register is a letter of undertaking .
It is assumed that this procedure is called by passing a register id which is of bond register type.
*/

procedure get_register_details(p_register_id                in number,
                               p_register_balance OUT NOCOPY number,
                               p_register_expiry_date OUT NOCOPY date,
                               p_lou_flag OUT NOCOPY varchar2);

end jai_cmn_bond_register_pkg ;
 

/
