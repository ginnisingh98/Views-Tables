--------------------------------------------------------
--  DDL for Package JAI_CMN_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_utils.pls 120.3 2007/04/12 12:41:09 ssawant ship $ */


/********************************************************************************************************
 FILENAME      :  ja_in_util_pkg_s.sql

 Created By    : ssumaith

 Created Date  : 29-Nov-2004

 Bug           : 4033992

 Purpose       :  Check whether The India Localization functionality should be used or not.

 Called from   : All india Localization triggers on base APPS tables

 --------------------------------------------------------------------------------------------------------
 CHANGE HISTORY:
 --------------------------------------------------------------------------------------------------------
 S.No      Date          Author and Details
 --------------------------------------------------------------------------------------------------------
 1.        2004/11/29   ssumaith - bug# 4033992 - File version 115.0

                        created the package spec for the common utility which will be used to check
                        if India Localization funtionality is being used.

                        This function check_jai_exists is to be called from all India localization triggers.
                        The  parameter - p_calling_object is a mandatory one and will have the name of the
                        trigger which calls the package.
                        The other parameters are optional , but one of them needs to be passed.
                        The second parameter is inventory_organization_id
                        The Third Parameter  is Operating_unit
                        The fouth Parameter  is Set_of_books_id
                        The fifth and sixth parameters are for future use.
                        The fifth parameter - p_value_string has the values passed seperated by colons
                        The sixth parameter - p_format_string has the corresponding labels seperated by colons,
                        which inform what each value is.

                        Example call to the package can be :

                        JA_IN_UTIL.CHECK_JAI_EXISTS(
                                                    P_CALLING_OBJECT => 'TRIGGER NAME'          ,
                                                    P_ORG_ID         => :New.org_id             ,
                                                    P_Value_string   => 'OM:OE_ORDER_LINES_ALL' ,
                                                    p_format_string  => 'MODULE NAME:TABLE NAME'
                                                   );


2. 08-Jun-2005  Version 116.1 jai_cmn_utils -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

3.     14-Jun-2005      rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.
      This activity is done as a part of R12 initiatives.
                        As part OF R12 Inititive Inventory conversion the OPM code IS commented

4      06-Jul-2005 rallamse for bug# PADDR Elimination
                   1. Removed the procedures ja_in_put_locator , ja_in_set_locator and ja_in_get_locator
          from both the specification and body.

5.     12-Jul-2005       Sanjikum for Bug#4483042, Version 117.2
                         1) Added a new function validate_po_type

5.     06-Dec-2005       rallamse for Bug#4773914, Version 120.2
                         1) Added a new function get_operating_unit

6.     26-FEB-2007   SSAWANT , File version 120.3
                     Forward porting the change in 11.5 bug 4903380 to R12 bug no 5039365.

		     Added a function return_valid_date. This function would take varchar2 as input. If
                     this input is a date then it would return the same otherwise it would return NULL.
                     This function is currently used in JAINASST.rdf and JAINYEDE.rdf.

                     Dependency
                     ----------
                       Yes



***************************************************************************************************************/
/************************************************************************************************************************

Created By      : Sanjikum

Creation Date   : 28-Oct-2004

Enhancement Bug : 3964409

Purpose         : This procedure updates the JAI_CMN_RG_SLNOS table.
                  1) If there are no record existing, then it inserts the record into
                     JAI_CMN_RG_SLNOS and then updates the same.
                  2) If there are some records existing, but they are not for current year,
                     then it updates the record again

Dependency     :

Change History :


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
ja_in_create_3964409_apps.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.0                  3964409                          1. ja_in_create_3964409_apps.sql        115.0       Sanjikum 28/10/2004
                                                        2. ja_in_create_3964409_ja.sql          115.0       Sanjikum 28/10/2004
                                                        3. ja_in_datafix_po_3964409.sql         115.0       Sanjikum 28/10/2004

******************************************************************************************************************************/

  FUNCTION check_jai_exists(p_calling_object      VARCHAR2                                                   ,
                            p_inventory_orgn_id   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE    DEFAULT NULL ,
                            p_org_id              HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE       DEFAULT NULL ,
                            p_set_of_books_id     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE         DEFAULT NULL ,
                            p_value_string        VARCHAR2                                      DEFAULT NULL ,
                            p_format_string       VARCHAR2                                      DEFAULT NULL
                           ) RETURN BOOLEAN;



/************************************************************************************************************************

Created By      : rallamse
Creation Date   : 06-Dec-2005
Enhancement Bug : 4773914
Purpose         : This function get_operating_unit returns operating unit based on inventory organization id.
Dependency      : This introduces a dependacy
Change History :


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

******************************************************************************************************************************/
FUNCTION get_operating_unit (
                              p_calling_object      VARCHAR2                                           ,
                              p_inventory_orgn_id   ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_ID%TYPE
                            ) RETURN NUMBER;

PROCEDURE update_rg_slno(
      pn_organization_id  IN  NUMBER,
      pn_location_id      IN  NUMBER,
      pv_register_type    IN  VARCHAR2,
      pn_fin_year         IN  NUMBER,
      pn_txn_amt          IN  NUMBER,
      pn_slno OUT NOCOPY NUMBER,
      pn_opening_balance OUT NOCOPY NUMBER,
      pn_closing_balance OUT NOCOPY NUMBER
      );

FUNCTION currency_conversion(
      c_set_of_books_id In Number,
      c_from_currency_code In varchar2,
      c_conversion_date in date,
      c_conversion_type in varchar2,
      c_conversion_rate in number
      ) return number ;

PROCEDURE print_log(
      filename  VARCHAR2,
      text_to_write VARCHAR2
      ) ;
--As part OF R12 Inititive Inventory conversion the OPM code IS commented
/*FUNCTION opm_uom_version(
      from_uom varchar2,
      to_uom varchar2,
      p_item_id number
      ) RETURN NUMBER;

FUNCTION get_opm_assessable_value
(p_item_id number,
p_qty number,
p_exted_price number,
P_Cust_Id Number Default 0
) RETURN NUMBER ;*/


procedure get_le_info
(
p_api_version             IN    NUMBER             ,
p_init_msg_list           IN    VARCHAR2           ,
p_commit                  IN    VARCHAR2           ,
p_ledger_id               IN    NUMBER             ,
p_bsv                     IN    VARCHAR2           ,
p_org_id                  IN    NUMBER             ,
x_return_status           OUT   NOCOPY  VARCHAR2   ,
x_msg_count               OUT   NOCOPY  NUMBER     ,
x_msg_data                OUT   NOCOPY  VARCHAR2   ,
x_legal_entity_id         OUT   NOCOPY  NUMBER     ,
x_legal_entity_name       OUT   NOCOPY  VARCHAR2
);

FUNCTION validate_po_type(p_po_type 		IN 	VARCHAR2	DEFAULT NULL,
			  p_style_id		IN	NUMBER		DEFAULT NULL,
			  p_po_header_id	IN	NUMBER		DEFAULT NULL
		   ) RETURN BOOLEAN;
/*Bug5039365 by ssawant*/
FUNCTION return_valid_date( p_validate_text VARCHAR2 ) RETURN DATE ;

END jai_cmn_utils_pkg;

/
