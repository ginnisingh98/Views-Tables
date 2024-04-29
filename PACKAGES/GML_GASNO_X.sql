--------------------------------------------------------
--  DDL for Package GML_GASNO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_GASNO_X" AUTHID CURRENT_USER as
/* $Header: GMLSNOXS.pls 115.2 99/07/16 06:19:02 porting ship  $     */
/*============================  GML_GASNO_X  ================================*/
/*===========================================================================
  PACKAGE NAME:         GML_GASNO_X

  DESCRIPTION:          Contains the stub procedures called during the Gateway
                        export process.  These procedures may be customized as
                        necessary to populate extension tables.

  CLIENT/SERVER:        Server

  LIBRARY NAME:         None

  PROCEDURE/FUNCTIONS:  Populate_SHP_Ext()
                        Populate_STX_Ext()
                        Populate_ORD_Ext()
                        Populate_OAC_Ext()
                        Populate_OTX_Ext()
                        Populate_DTL_Ext()
                        Populate_DAC_Ext()
                        Populate_DTX_Ext()
                        Populate_ALL_Ext()

  NOTES:                To run the script:

                        sql> start GMLSNOXS.pls

  HISTORY               02/15/99  dgrailic  Created.
                        05/12/99  dgrailic  For 11i, modified names from ECE_ to GML_

/*===========================================================================
  PROCEDURE NAME:       Populate_SHP_Ext

  DESCRIPTION:          Stub procedure to populate shipment extension table.

  PARAMETERS:           p_SHP_Key    IN NUMBER
                        p_SHP_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       03/10/99  mmacary   Created.

 ===========================================================================*/

 PROCEDURE Populate_SHP_Ext (
                    p_SHP_Key    IN NUMBER,
                    p_SHP_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_STX_Ext

  DESCRIPTION:          Stub procedure to populate Shipment text ext. table

  PARAMETERS:           p_STX_Key    IN NUMBER
                        p_STX_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_STX_Ext (
                    p_STX_Key    IN NUMBER,
                    p_STX_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_ORD_Ext

  DESCRIPTION:          Stub procedure to populate Order extension table.

  PARAMETERS:           p_ORD_Key    IN NUMBER
                        p_ORD_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_ORD_Ext (
                    p_ORD_Key    IN NUMBER,
                    p_ORD_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_OAC_Ext

  DESCRIPTION:          Stub procedure to populate Order Charges ext table.

  PARAMETERS:           p_OAC_Key    IN NUMBER
                        p_OAC_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_OAC_Ext (
                    p_OAC_Key    IN NUMBER,
                    p_OAC_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_OTX_Ext

  DESCRIPTION:          Stub procedure to populate Order Text extension table.

  PARAMETERS:           p_OTX_Key    IN NUMBER
                        p_OTX_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_OTX_Ext (
                    p_OTX_Key    IN NUMBER,
                    p_OTX_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_DTL_Ext

  DESCRIPTION:          Stub procedure to populate Detail extension table.

  PARAMETERS:           p_DTL_Key    IN NUMBER
                        p_DTL_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_DTL_Ext (
                    p_DTL_Key    IN NUMBER,
                    p_DTL_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_DAC_Ext

  DESCRIPTION:          Stub procedure to populate Detail Charges  ext table.

  PARAMETERS:           p_DAC_Key    IN NUMBER
                        p_DAC_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_DAC_Ext (
                    p_DAC_Key    IN NUMBER,
                    p_DAC_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_DTX_Ext

  DESCRIPTION:          Stub procedure to populate Detail Text  extension table.

  PARAMETERS:           p_DTX_Key    IN NUMBER
                        p_DTX_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_DTX_Ext (
                    p_DTX_Key    IN NUMBER,
                    p_DTX_Table  IN ece_flatfile_pvt.Interface_tbl_type );

/*===========================================================================
  PROCEDURE NAME:       Populate_ALL_Ext

  DESCRIPTION:          Stub procedure to populate Detail allocations (lot info)
                        extension table.

  PARAMETERS:           p_ALL_Key    IN NUMBER
                        p_ALL_Table  IN ece_flatfile_pvt.Interface_tbl_type

  DESIGN REFERENCES:    GASNO_hld.rtf.

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/24/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_ALL_Ext (
                    p_ALL_Key    IN NUMBER,
                    p_ALL_Table  IN ece_flatfile_pvt.Interface_tbl_type );

END GML_GASNO_X;

 

/
