--------------------------------------------------------
--  DDL for Package Body INV_COPY_ORG_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COPY_ORG_REPORT_PUB" AS
-- $Header: INVVCORB.pls 115.5 2002/05/16 14:40:55 pkm ship    $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVVCORB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Body of Inv_Copy_Org_Report                                        |
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
                              )
IS
BEGIN
  IF( UPPER(purge_interface) = 'Y' ) THEN
    DELETE FROM mtl_copy_org_interface
    WHERE group_code = p_group_code;
  END IF;

  x_retcode  := 0;

EXCEPTION

  WHEN OTHERS THEN

    IF
      FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( 'Inv_Copy_Org_Report_Pub', 'Purge_Reports_Data' );
    END IF;

   x_errbuf   := FND_MSG_PUB.Get( p_encoded  =>  FND_API.G_FALSE );
   x_retcode  := 2;

END purge_interface_data;

/*
** -------------------------------------------------------------------------
** Procedure: purge_previous_reports_data
** Description: Purges any records in the copy organization report
**              table that correspond to a completed cocurrent request
** --------------------------------------------------------------------------
*/

PROCEDURE purge_previous_reports_data
IS
  CURSOR concurrent_req_id_cursor IS
  SELECT DISTINCT request_id
  FROM mtl_copy_org_report;

  phase             VARCHAR2( 200 );
  status            VARCHAR2( 200 );
  dev_phase         VARCHAR2( 30 );
  dev_status        VARCHAR2( 30 );
  message           VARCHAR2( 250 );
  returned_val      BOOLEAN;
  request_id_rec    concurrent_req_id_cursor%ROWTYPE;

BEGIN
  FOR request_id_rec IN concurrent_req_id_cursor LOOP
    returned_val := FND_CONCURRENT.GET_REQUEST_STATUS
      ( request_id_rec.request_id
      , NULL
      , NULL
      , phase
      , status
      , dev_phase
      , dev_status, message
      );

    IF UPPER( dev_phase )  =  'COMPLETE' THEN
      DELETE FROM
        mtl_copy_org_report
      WHERE
        request_id = request_id_rec.request_id;
    END IF;

  END LOOP;
END purge_previous_reports_data;


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

PROCEDURE purge_reports_data
( x_retcode        OUT  VARCHAR2
, x_errbuf         OUT  VARCHAR2
, p_group_code     IN   VARCHAR2
)
IS
BEGIN

  DELETE FROM mtl_copy_org_report
  WHERE group_code = p_group_code;

  purge_previous_reports_data;
  COMMIT;

  x_retcode  := 0;

EXCEPTION

  WHEN OTHERS THEN

    IF
      FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( 'Inv_Copy_Org_Report_Pub', 'Purge_Reports_Data' );
    END IF;

   x_errbuf   := FND_MSG_PUB.Get( p_encoded  =>  FND_API.G_FALSE );
   x_retcode  := 2;

END purge_reports_data;


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

FUNCTION clob_to_varchar( lobsrc IN CLOB ) RETURN VARCHAR2
IS
  buffer VARCHAR2( 1800 );
  amount NUMBER;
BEGIN
  amount := 1800;

  IF lobsrc IS NOT NULL THEN
    DBMS_LOB.READ( lobsrc, amount, 1, buffer );
  END IF;

  RETURN buffer;
END clob_to_varchar;

/*
** -------------------------------------------------------------------------
** Function: submit_report_conc_req
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
RETURN NUMBER
IS
  success      BOOLEAN;
  request_id   NUMBER;
BEGIN
  request_id := -1;
  success := fnd_submit.set_request_set('INV', 'INVGCORPSET');
  IF( success ) THEN
    success := fnd_submit.submit_program( 'INV'
                                        , 'INVGCORP'
					, 'INVGCORP10'
					, p_group_code
					);

    success := fnd_submit.submit_program( 'INV'
                                        , 'INVCORPP'
					, 'INVGCORP20'
					, p_group_code
					);

    success := fnd_submit.submit_program( 'INV'
                                        , 'INVISCORP'
	  				, 'INVGCORP20'
					, p_group_code
					, purge_interface
					);

    request_id := fnd_submit.submit_set( NULL, FALSE );
  END IF;

  RETURN request_id;

END submit_report_conc_req;

END Inv_Copy_Org_Report_Pub;

/
