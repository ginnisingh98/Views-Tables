--------------------------------------------------------
--  DDL for Package PA_GMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GMS_API" AUTHID CURRENT_USER AS
/* $Header: PAXGMS1S.pls 120.3 2006/08/26 11:22:30 asubrama noship $ */

     -- -------------------------------------------------------------------
     -- Function to verify whether GRANTS is installed or not
     -- ------------------------------------------------------------------
      FUNCTION VERT_INSTALL return BOOLEAN ;

    -- ---------------------------------------------------------------
    -- Function to validate adjustments  on an expenditure item
    -- this function may be used for additional validation for
    -- for testing eligibility for expenditure item adjustment.
    --  Parameters :
    -- ---------------------------------------------------------------
	FUNCTION VERT_ALLOW_ADJUSTMENTS( X_EXPENDITURE_ITEM_ID IN  NUMBER )
	return BOOLEAN ;
    -- -----------------------------------------------------------------
    -- Procedure to validate Transfer on an expenditure item .
    -- Additional validation will be done to validate expenditure item for
    -- Transfer
    -- ------------------------------------------------------------------
    FUNCTION VERT_TRANSFER( X_EXP_ITEM_ID IN NUMBER  , X_ERROR IN OUT NOCOPY VARCHAR2 )
    RETURN BOOLEAN ;

    PROCEDURE VERT_ADJUST_ITEMS( X_CALLING_PROCESS 	IN   VARCHAR2 ,
                                 X_ROWS             IN   NUMBER,
								 X_status		IN OUT NOCOPY   NUMBER );

    -- ------------------------------------------------------
    -- API to allow vertical application to compare awards
    -- X_ADJUST_ACTION = 'MASADJUST'
    -- -------------------------------------------------------
    FUNCTION  VERT_ALLOW_ACTION(X_ADJUST_ACTION IN VARCHAR2) RETURN VARCHAR2 ;

   -- ----------------------------------------------------------
   -- Supplier Invoice Interface logic of creating ADLS.
   -- LD PA Interface  logic of creating ADLS.
   -- trx_interface - Creates ADLS for the new expenditure items
   --               created for PA  Interface from payables/LD.
   --               This is called after PA_TRX_IMPORT.NEWexpend.
   -- -----------------------------------------------------------
  PROCEDURE  VERT_TRX_INTERFACE( X_USER              IN NUMBER
                          , X_LOGIN             IN NUMBER
                          , X_MODULE            IN VARCHAR2
                          , X_CALLING_PROCESS   IN VARCHAR2
                          , ROWS                IN BINARY_INTEGER
                          , X_STATUS            IN OUT NOCOPY NUMBER
                          , X_GL_FLAG           IN VARCHAR2 ) ;

  -- ----------------------------------------------------------------
  -- API to allow vertical applications to take actions following the
  -- creation of AP distribution lines.
  -- This is called from PA_XFER_ADJ.
  -- -----------------------------------------------------------------
  PROCEDURE VERT_PAAP_SI_ADJUSTMENTS( x_expenditure_item_id      IN NUMBER,
							     x_invoice_id               IN NUMBER,
								 x_distribution_line_number IN NUMBER,
								 x_cdl_line_num				IN NUMBER,
								 x_project_id               IN NUMBER,
								 x_task_id                  IN NUMBER,
								 status                 IN OUT NOCOPY NUMBER ) ;

  -- ----------------------------------------------------------------
  -- API to allow vertical applications to validate transaction
  -- interface. This is called from PA_TRX_IMPORTS just after ValidateItem
  -- -----------------------------------------------------------------
  PROCEDURE VERT_APP_VALIDATE(  X_transaction_source    IN VARCHAR2,
                                X_CURRENT_BATCH         IN VARCHAR2,
                                X_txn_interface_id      IN NUMBER ,
								X_Org_id		IN NUMBER,
                                X_status            IN OUT NOCOPY Varchar2 ) ;



  PROCEDURE VERT_SI_ADJ ( x_expenditure_item_id			IN 	NUMBER,
						  x_invoice_id					IN  NUMBER,
						  x_distribution_line_number	IN  NUMBER,
						  x_project_id					IN  NUMBER,
						  x_task_id						IN  NUMBER,
						  status				    IN OUT NOCOPY  NUMBER ) ;

  FUNCTION IS_SPONSORED_PROJECT ( X_project_id	IN NUMBER ) return BOOLEAN ;

  -- ----------------------------------------------------------------------------------------
  -- This function is called from PAAPIMP_PKG. OGM needs to consider award_id in the GROUP BY
  -- clause used for NET_ZERO_ADJUSTMENTS. SO OGM returns award_ID for operating unit having
  -- grants installation.
  -- -----------------------------------------------------------------------------------------
  FUNCTION VERT_GET_AWARD_ID ( x_award_set_id   		  IN NUMBER,
							   x_invoice_id   			  IN NUMBER,
							   x_distribution_line_number IN NUMBER ) return NUMBER ;

/* R12 Changes Start */
  PROCEDURE VERT_SET_ADJUST_ACTION(p_adjust_action IN VARCHAR2);

  PROCEDURE VERT_SET_PROJECT_ID( p_source_project_id IN VARCHAR2
			       , p_dest_project_id IN VARCHAR2);

  PROCEDURE VERT_SET_AWARD_ID( p_source_award_id IN VARCHAR2
			     , p_dest_award_id IN VARCHAR2);

  PROCEDURE VERT_GET_SRC_DEST_AWARD_ID( X_source_award_id OUT NOCOPY VARCHAR2
			              , X_dest_award_id OUT NOCOPY VARCHAR2);

  FUNCTION VERT_EI_AWD_EQUALS_SRC_AWD(p_expenditure_item_id NUMBER)
  RETURN VARCHAR2;

  FUNCTION VERT_GET_EI_AWARD_ID(p_expenditure_item_id NUMBER)
  RETURN NUMBER;
/* R12 Changes End */


/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input and returns the award associated with
   this expenditure item.
   The function returns NULL if no award is associated with the expenditure item.
*/
  FUNCTION VERT_GET_AWARD_NUMBER(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ) RETURN VARCHAR2;

/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input.
   If grants is not installed then the function returns 'Y'.
   Else if the exenditure item belongs to a sponsored project:
     The function determines the Award Number and verifies if the Award Number falls in the specified range.
       If yes, then the function returns 'Y'.
       If no, then the funciton returns 'N'.
  If the expenditure item belongs to a non-sponsored project:
    If award range is not specified then the function returns 'Y'
    If award range is specified then the function returns 'N'
*/
  FUNCTION VERT_IS_AWARD_WITHIN_RANGE(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ,p_from_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ,p_to_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ) RETURN VARCHAR2;

END PA_GMS_API;

 

/
