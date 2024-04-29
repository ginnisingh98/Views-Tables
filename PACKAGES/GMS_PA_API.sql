--------------------------------------------------------
--  DDL for Package GMS_PA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PA_API" AUTHID CURRENT_USER AS
/* $Header: gmspax1s.pls 120.3 2007/02/06 09:51:25 rshaik ship $ */


 	SOURCE_AWARD_ID 		NUMBER ;
	x_default_dist_award_id         NUMBER ;
 	DEST_AWARD_ID   		NUMBER ;
 	SOURCE_PROJECT_ID 		NUMBER ;
	DEST_PROJECT_ID  		NUMBER ;
	X_ALLOWABLE_ID  		NUMBER ;
	X_END_DATE      DATE ;
	X_EXPENDITURE_TYPE VARCHAR2(30) ;
	X_ITEM_DATE     DATE ;
	X_TYPE          VARCHAR2(30) ;
        X_error         VARCHAR2(100) ;
        X_adj_action    VARCHAR2(30) ;
		X_message_num   NUMBER(1); -- Bug 2458518
	FUNCTION return_error return VARCHAR2 ;

	-- ------------------------------------------------------------------
	-- This procedure is called by GMS.pld to copy the award information .
	-- ------------------------------------------------------------------
	PROCEDURE GMS_SPLIT  (x_expenditure_item_id IN NUMBER ) ;

    	-- ------------------------------------------------------
        -- API to allow vertical application to compare awards
        -- X_ADJUST_ACTION = 'MASADJUST'
        -- -------------------------------------------------------
        FUNCTION  VERT_ALLOW_ACTION(X_ADJUST_ACTION IN VARCHAR2) RETURN VARCHAR2 ;


	PROCEDURE GMS_SET_AWARD(x_source_award_id IN NUMBER , x_dest_award_id IN NUMBER);

	PROCEDURE GMS_SET_PROJECT_ID(x_source_project_id IN NUMBER , x_dest_project_id IN NUMBER);

	-- ----------------------------------------------------------------------------------------
        -- This is called from PAXEIADJ.pll while overriding the Task validation . This will return
	-- the X_STATUS which will contain the error Label .
	-- ----------------------------------------------------------------------------------------
  	FUNCTION VERT_TRANSFER (X_EXP_ID 		IN NUMBER ,
                             	 X_STATUS               IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN ;

	-- ------------------------------------------------------------------
	-- This procedure is called form TRANSFER procedure in PAXTADJB.pls
        -- to create adls both for TRANSFER and MASSADJUST
	-- ------------------------------------------------------------------
         PROCEDURE VERT_ADJUST_ITEMS( X_CALLING_PROCESS 	IN   VARCHAR2 ,
                            	      X_ROWS                    IN   NUMBER,
				      X_status		        IN OUT NOCOPY   NUMBER);


	-- ------------------------------------------------------------------
        -- This is to verify whether the exp_item is trasnferable or not.
        -- We check expenditure_type,expenditure_date,stauts of the exp_id
	-- in AP and compare the source and dest awards .
	-- ------------------------------------------------------------------
	FUNCTION vert_allow_adjustments( x_expenditure_item_id IN  NUMBER )
	return BOOLEAN ;

   -- ----------------------------------------------------------
   -- Supplier Invoice Interface logic of creating ADLS.
   -- LD PA Interface  logic of creating ADLS.
   -- trx_interface - Creates ADLS for the new expenditure items
   --               created for PA  Interface from payables/LD.
   --               This is called after PA_TRX_IMPORT.NEWexpend.
   -- -----------------------------------------------------------
  PROCEDURE  vert_trx_interface( X_user              IN NUMBER
                          , X_login             IN NUMBER
                          , X_module            IN VARCHAR2
                          , X_calling_process   IN VARCHAR2
                          , Rows                IN BINARY_INTEGER
                          , X_status            IN OUT NOCOPY NUMBER
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
								X_org_id				IN NUMBER,
                                X_status            IN OUT NOCOPY Varchar2 ) ;



  PROCEDURE VERT_SI_ADJ ( x_expenditure_item_id			IN 	NUMBER,
						  x_invoice_id					IN  NUMBER,
						  x_distribution_line_number	IN  NUMBER,
						  x_project_id					IN  NUMBER,
						  x_task_id						IN  NUMBER,
						  status				    IN OUT NOCOPY  NUMBER ) ;

  FUNCTION IS_SPONSORED_PROJECT ( X_project_id	IN NUMBER ) return BOOLEAN ;


  -- --------------------------------------------------------------------
  -- BUG: 1332945 - GMS not doing validations for award informations.
  -- called from GMS_TXN_INTERFACE_AIT1
  -- file : gmstxntr.sql
  -- Gms_validations may reject transaction import records.
  -- --------------------------------------------------------------------
  PROCEDURE VERT_REJECT_TXN(	x_txn_interface_id		IN NUMBER,
								x_batch_name			IN varchar2,
								x_txn_source			IN VARCHAR2,
								X_status				IN VARCHAR2,
								X_calling_source		IN VARCHAR2 DEFAULT NULL ) ;

  -- ---------------------------------------------------------------------
  -- BUG:1380464 - net zero invoice items having different awards are not
  --               picked up by supplier invoice interface process.
  -- Call to this function is added in package PAAPIMP_PKG.
  -- ----------------------------------------------------------------------
  FUNCTION VERT_GET_AWARD_ID( x_award_set_id IN NUMBER,
							  x_invoice_id	 IN NUMBER,
							  x_dist_lno	 IN NUMBER ) return NUMBER ;

 -- -----------------------------------------------------------------------
 -- Function to check whether GMS is installed or not
 -- -----------------------------------------------------------------------
   FUNCTION VERT_INSTALL return BOOLEAN ;
 -- ----------------------------------------------------------------------
 -- Procedure to set the Adjust_action for recalculate raw-cost or burden-cost
 -- ----------------------------------------------------------------------
   PROCEDURE set_adjust_action(X_adjust_action IN VARCHAR2) ;


  PROCEDURE Override_Rate_Rev_Id(
                           p_tran_item_id          IN  number DEFAULT NULL,
                           p_tran_type             IN  Varchar2 DEFAULT NULL,
                           p_task_id         	   IN  number DEFAULT NULL,
                           p_schedule_type         IN  Varchar2 DEFAULT NULL,
                           p_exp_item_date         IN  Date DEFAULT NULL,
                           x_sch_fixed_date        OUT NOCOPY Date,
                           x_rate_sch_rev_id 	   OUT NOCOPY number,
                           x_status                OUT NOCOPY number ) ;

  --- pragma RESTRICT_REFERENCES (Override_Rate_Rev_Id, WNDS, WNPS ); /* commented as per 3786374 */

  -- ========================================================================================
  --		30-APR-2001	aaggarwa	BUG		: 1751995
  --								Description	: Multiple awards funding single projects causes
  --		  						burdening problem.
  --								Resolution	: PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING
  --		  						was modified for grants accounting to add award
  --		  						parameter for grouping. This will allow to create
  --		  						burden summarization lines for each award.
  -- ========================================================================================
  FUNCTION CLIENT_GROUPING
	(
		p_src_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
     		p_src_ind_expnd_type IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
		p_src_attribute1     IN PA_EXPENDITURE_TYPES.attribute1%TYPE ,
		v_grouping_method    IN varchar2
	) return varchar2 ;

  -- -----------------------------------------------------
  -- Function to check the award status. This function
  -- is called while doing adjustments in exp inquiry form.
  -- -----------------------------------------------------
  FUNCTION IS_AWARD_CLOSED(x_expenditure_item_id in number ,x_task_id in NUMBER ,x_doc_type in varchar2 default 'EXP') return varchar2 ; -- Bug 5726575

/* R12 Changes Start */
  -- -------------------------------------------------------------------------
  -- This function gets the award id for the specified expenditure item
  -- -------------------------------------------------------------------------
  FUNCTION VERT_GET_EI_AWARD_ID(p_expenditure_item_id NUMBER)
  RETURN NUMBER;

  -- -------------------------------------------------------------------------
  -- This function checks whether the expenditure item belongs to the Source
  -- Award or not
  -- -------------------------------------------------------------------------
  FUNCTION CHECK_ADJUST_ALLOWED(x_expenditure_item_id IN NUMBER)
  RETURN BOOLEAN;
/* R12 Changes End */


/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input and returns the award associated with
   this expenditure item.
   The function raises an exception if no award is associated with the expenditure item.
*/
  FUNCTION VERT_GET_AWARD_NUMBER(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ) RETURN VARCHAR2;

/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input.
   If the exenditure item belongs to a sponsored project:
     The function determines the Award Number and verifies if the Award Number falls in the specified range.
       If yes, then the function returns 'Y'.
       If no, then the funciton returns 'N'.
   If the expenditure item belongs to a non-sponsored project:
     If award range is not specified, then the function returns 'Y'.
     If award range is specified, then the function returns 'N'.
*/
  FUNCTION VERT_IS_AWARD_WITHIN_RANGE(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ,p_from_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ,p_to_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ) RETURN VARCHAR2;

END GMS_PA_API;

/
