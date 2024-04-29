--------------------------------------------------------
--  DDL for Package Body GML_GASNO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_GASNO_X" as
/* $Header: GMLSNOXB.pls 115.2 99/07/16 06:18:58 porting ship  $     */
/*============================  GML_GASNO_X  ================================*/
/*============================================================================
  PURPOSE:  Creates stub procedures for extracting Order data into
            Gateway extension tables.  These procedures are called during
            the standard Gateway Outbound OPM PO ack export process, and
            may be customized as necessary.

            Each procedure takes two parameters:  a 'key' value, and a
            PL/SQL table.

            The 'key' value is the TRANSACTION_RECORD_ID value, which is
            the primary key for both the interface table and the extension
            table.

            'Source_tbl_type' is a PL/SQL table typedef with the following
            structure:

            data_loc_id             NUMBER
            table_name              VARCHAR2(50)  -- Interface table name
            column_name             VARCHAR2(50)  -- Interface column name
            base_table_name         VARCHAR2(50)  -- Application table name
            base_column_name        VARCHAR2(50)  -- Application column name
            xref_category_id        NUMBER        -- Cross-reference category
            xref_key1_source_column VARCHAR2(50)  -- Cross-reference source 1
            xref_key2_source_column VARCHAR2(50)  -- Cross-reference source 2
            xref_key3_source_column VARCHAR2(50)  -- Cross-reference source 3
            xref_key4_source_column VARCHAR2(50)  -- Cross-reference source 4
            xref_key5_source_column VARCHAR2(50)  -- Cross-reference source 5
            data_type               VARCHAR2(50)  -- Data type
            data_length             NUMBER        -- Data length
            int_val                 VARCHAR2(400) -- Interface table value
            ext_val1                VARCHAR2(80)  -- Cross-reference value 1
            ext_val2                VARCHAR2(80)  -- Cross-reference value 2
            ext_val3                VARCHAR2(80)  -- Cross-reference value 3
            ext_val4                VARCHAR2(80)  -- Cross-reference value 4
            ext_val5                VARCHAR2(80)  -- Cross-reference value 5

            Each record in the PL/SQL table represents a single column
            in the interface table.  The 'int_val' attribute holds the
            value stored in the interface table column (converted to
            VARCHAR2).


  NOTES:    To run the script:

            sql> start GMLSNOXB.pls

  HISTORY   02/24/99  dgrailic  Created.
            03/10/99  mmacary   modified.
            05/12/99  dgrailic  For 11i, modified names from ECE_ to GML_
===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:      Populate_SHP_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Shipment level.

===========================================================================*/

  PROCEDURE Populate_SHP_Ext (
                     p_SHP_Key    IN NUMBER,
                     p_SHP_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_SHP_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_STX_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Shipment Text level.

===========================================================================*/

  PROCEDURE Populate_STX_Ext (
                     p_STX_Key    IN NUMBER,
                     p_STX_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_STX_Ext;


/*===========================================================================

  PROCEDURE NAME:      Populate_ORD_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Order level.

===========================================================================*/

  PROCEDURE Populate_ORD_Ext (
                     p_ORD_Key    IN NUMBER,
                     p_ORD_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_ORD_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_OAC_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Order Charges level.

===========================================================================*/

  PROCEDURE Populate_OAC_Ext (
                     p_OAC_Key    IN NUMBER,
                     p_OAC_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_OAC_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_OTX_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Order Text level.

===========================================================================*/

  PROCEDURE Populate_OTX_Ext (
                     p_OTX_Key    IN NUMBER,
                     p_OTX_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_OTX_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_DTL_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Datail level.

===========================================================================*/

  PROCEDURE Populate_DTL_Ext (
                     p_DTL_Key    IN NUMBER,
                     p_DTL_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_DTL_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_DAC_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Detail Charges level.

===========================================================================*/

  PROCEDURE Populate_DAC_Ext (
                     p_DAC_Key    IN NUMBER,
                     p_DAC_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_DAC_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_DTX_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Detail Text level.

===========================================================================*/

  PROCEDURE Populate_DTX_Ext (
                     p_DTX_Key    IN NUMBER,
                     p_DTX_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_DTX_Ext;

/*===========================================================================

  PROCEDURE NAME:      Populate_ALL_Ext

  PURPOSE:             This procedure populates the extension tables at the
                       Datail Allocations (lot info) level.

===========================================================================*/

  PROCEDURE Populate_ALL_Ext (
                     p_ALL_Key    IN NUMBER,
                     p_ALL_Table  IN ece_flatfile_pvt.Interface_tbl_type )
  IS

  BEGIN

    /*
    **
    **  Custom code to populate the Delivery level extension table goes here.
    **
    */

    NULL;

  END Populate_ALL_Ext;


END GML_GASNO_X;

/
