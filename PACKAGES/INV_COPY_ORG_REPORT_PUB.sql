--------------------------------------------------------
--  DDL for Package INV_COPY_ORG_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COPY_ORG_REPORT_PUB" AUTHID CURRENT_USER AS
-- $Header: INVVCORS.pls 115.4 2002/05/16 14:40:58 pkm ship    $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVVCORS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of Inv_Copy_Org_Report                               |
--|                                                                       |
--| HISTORY                                                               |
--|     10/02/2001 Vincent Chu     Created                                |
--+======================================================================*/


/*
** -------------------------------------------------------------------------
** Procedure: purge_interface_data
** Description: Purges the records in the copy organization interface
**              table that correspond to a particular group code
** Output:
**      x_retcode
**              return status indicating success, error, unexpected error
**      x_errbuf
**              contains the message text, if there are any
**
** Input:
**      p_group_code
**              the group code that corresponds to the records that are to
**              be purged from the interface table
**      purge_interface
**              purges the interface table only if this is set to 'Y'
** --------------------------------------------------------------------------
*/

    PROCEDURE purge_interface_data( x_retcode        OUT  VARCHAR2
                                  , x_errbuf         OUT  VARCHAR2
                                  , p_group_code     IN VARCHAR2
                                  , purge_interface  IN VARCHAR2
                                  );

/*
** -------------------------------------------------------------------------
** Procedure: purge_reports_data
** Description: Purges the records in the copy organization report
**              table that correspond to a particular group code
** Output:
**      x_retcode
**              return status indicating success, error, unexpected error
**      x_errbuf
**              contains the message text, if there are any
**
** Input:
**      p_group_code
**              the group code that corresponds to the records that are to
**              be purged from the report table
** --------------------------------------------------------------------------
*/

    PROCEDURE purge_reports_data( x_retcode     OUT   VARCHAR2
                                , x_errbuf      OUT   VARCHAR2
                                , p_group_code  IN    VARCHAR2
                                );

/*
** -------------------------------------------------------------------------
** Function: clob_to_varchar
** Description: Takes in a CLOB database object and returns the
**              corresponding VARCHAR2 object
** Input:
**      lobsrc
**              The CLOB to be converted into a VARCHAR2 string
**
** Returns:
**      The VARCHAR2 string that was converted from the passed in CLOB
** --------------------------------------------------------------------------
*/

    FUNCTION clob_to_varchar ( lobsrc IN CLOB ) return VARCHAR2;

/*
** -------------------------------------------------------------------------
** Procedure: submit_report_conc_req
** Description: Submits a request to run the copy organization report
**              request set, which generates a report and purges the
**              corresponding report table and interface table data
** Input:
**      p_group_code
**              the group code that corresponds to particular run of
**              copy organization, for which a report is to be generated
**      purge_interface
**              purges the interface table only if this is set to 'Y'
** Returns:
**      ID of the request that runs the report request set
** --------------------------------------------------------------------------
*/

    FUNCTION submit_report_conc_req ( p_group_code    IN VARCHAR2
                                    , purge_interface IN VARCHAR2
                                    )
    RETURN NUMBER;

END Inv_Copy_Org_Report_Pub;

 

/
