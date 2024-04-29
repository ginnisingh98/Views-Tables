--------------------------------------------------------
--  DDL for Package Body PA_GMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GMS_API" AS
-- $Header: PAXGMS1B.pls 120.3 2006/08/26 11:22:54 asubrama noship $

--  ---------------------------------------------------------
-- API for GMS to determine whether to allow adjustments or
-- not.
-- -----------------------------------------------------------
   FUNCTION vert_allow_adjustments (
      x_expenditure_item_id      IN       NUMBER
   )
      RETURN BOOLEAN IS
      x_return                      BOOLEAN := FALSE;
   BEGIN
-- -------------------------------------------------
-- Vertical application will override the code here.
-- If Grants is enabled then only execute grants call.
-- -------------------------------------------------
--	IF gms_install.enabled THEN -- bug 3002305.
	IF pa_gms_api.vert_install THEN
      		x_return  := gms_pa_api.vert_allow_adjustments (
                 x_expenditure_item_id);
	END IF ;
      RETURN x_return;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END vert_allow_adjustments;

-- ------------------------------------------------------
-- ------------------------------------------------------
-- API to allow vertical application to perform Adjustment
-- actions.
-- -------------------------------------------------------
  FUNCTION vert_transfer (
   		x_exp_item_id	IN NUMBER,
 		x_error 	IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS
      x_return                      BOOLEAN := FALSE;
	BEGIN
-- --------------------------------------------------
-- Vertical application will override the code here.
-- If Grants is enabled then only execute grants call.
-- -------------------------------------------------
--	IF gms_install.enabled THEN -- Bug 3002305
	IF pa_gms_api.vert_install THEN
      		x_return   := gms_pa_api.vert_transfer (
                 		x_exp_item_id ,
				x_error) ;
	END IF ;
      RETURN x_return;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END vert_transfer;

-- ------------------------------------------------------
-- API to allow vertical application to perform Adjustment
-- actions.
-- -------------------------------------------------------
   PROCEDURE vert_adjust_items (
      x_calling_process          IN       VARCHAR2,
      x_rows                     IN       NUMBER,
      x_status                   IN OUT  NOCOPY   NUMBER
   ) IS
   BEGIN
   --   IF x_status IS NOT NULL THEN
   --      RETURN;
   --   END IF;

-- -------------------------------------------------
-- Vertical application will override the code here.
-- If Grants is enabled then only execute grants call.
-- -------------------------------------------------
--	IF gms_install.enabled THEN -- Bug 3002305
	IF pa_gms_api.vert_install THEN
	      gms_pa_api.vert_adjust_items (x_calling_process,
		 x_rows,
		 x_status
	      );
	END IF ;
   END vert_adjust_items;

-- ------------------------------------------------------
-- API to allow vertical application to compare awards
-- X_ADJUST_ACTION = 'MASSADJUST'
-- -------------------------------------------------------
   FUNCTION vert_allow_action (
      x_adjust_action            IN       VARCHAR2
   )
      RETURN VARCHAR2 IS
      x_return                      VARCHAR2(1);
   BEGIN
      x_return                   := 'N';
-- -------------------------------------------------
-- Vertical application will override the code here.
-- If Grants is enabled then only execute grants call.
-- -------------------------------------------------
--	IF gms_install.enabled THEN -- Bug 3002305
	IF pa_gms_api.vert_install THEN
	      x_return  := gms_pa_api.vert_allow_action (x_adjust_action);
	END IF ;
      RETURN x_return;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END vert_allow_action;

-- --------------------------------------------------------
--
-- Supplier Invoice Interface logic of creating ADLS.
-- LD PA Interface  logic of creating ADLS.
-- trx_interface - Creates ADLS for the new expenditure items
--               created for PA  Interface from payables/LD.
--               This is called after PA_TRX_IMPORT.NEWexpend.
-- -----------------------------------------------------------
   PROCEDURE vert_trx_interface (
      x_user                     IN       NUMBER,
      x_login                    IN       NUMBER,
      x_module                   IN       VARCHAR2,
      x_calling_process          IN       VARCHAR2,
      rows                       IN       BINARY_INTEGER,
      x_status                   IN OUT NOCOPY   NUMBER,
      x_gl_flag                  IN       VARCHAR2
   ) IS
   BEGIN
--	IF NOT gms_install.enabled THEN -- Bug 3002305
	IF NOT pa_gms_api.vert_install THEN
	   RETURN ;
	END IF ;
-- -------------------------------------------------
-- Vertical application will override the code here.
-- -------------------------------------------------
      gms_pa_api.vert_trx_interface (x_user,
         x_login,
         x_module,
         x_calling_process,
         rows,
         x_status,
         x_gl_flag
      );
   END vert_trx_interface;

-- ----------------------------------------------------------------
-- API to allow vertical applications to take actions following the
-- creation of AP distribution lines.
-- This is called from PA_XFER_ADJ.
-- -----------------------------------------------------------------
   PROCEDURE vert_paap_si_adjustments (
      x_expenditure_item_id      IN       NUMBER,
      x_invoice_id               IN       NUMBER,
      x_distribution_line_number IN       NUMBER,
      x_cdl_line_num             IN       NUMBER,
      x_project_id               IN       NUMBER,
      x_task_id                  IN       NUMBER,
      status                     IN OUT NOCOPY   NUMBER
   ) IS
   BEGIN
--	IF NOT gms_install.enabled THEN -- Bug 3002305
	IF NOT pa_gms_api.vert_install THEN
	   RETURN ;
	END IF ;
-- -------------------------------------------------
-- Vertical application will override the code here.
-- -------------------------------------------------
      gms_pa_api.vert_paap_si_adjustments (x_expenditure_item_id,
         x_invoice_id,
         x_distribution_line_number,
         x_cdl_line_num,
         x_project_id,
         x_task_id,
         status
      );

   END vert_paap_si_adjustments;

-- -----------------------------------------------------------------
-- API to allow vertical applications to validate transaction
-- interface. This is called from PA_TRX_IMPORTS just after ValidateItem
-- -----------------------------------------------------------------
   PROCEDURE vert_app_validate (
      x_transaction_source       IN       VARCHAR2,
      x_current_batch            IN       VARCHAR2,
      x_txn_interface_id         IN       NUMBER,
      x_org_id                   IN       NUMBER,
      x_status                   IN OUT NOCOPY   VARCHAR2
   ) IS
   BEGIN
      IF x_status IS NOT NULL THEN
         RETURN;
      END IF;

-- -------------------------------------------------
-- Vertical application will override the code here.
-- -------------------------------------------------
--      IF    gms_install.enabled (x_org_id)  -- do we need org here ? -- Bug 3002305
      IF    pa_gms_api.vert_install
         OR NVL (x_org_id,
               0
            ) = 0 THEN
         gms_pa_api.vert_app_validate (x_transaction_source,
            x_current_batch,
            x_txn_interface_id,
            x_org_id,
            x_status
         );
      END IF;
   END vert_app_validate;

   PROCEDURE vert_si_adj (
      x_expenditure_item_id      IN       NUMBER,
      x_invoice_id               IN       NUMBER,
      x_distribution_line_number IN       NUMBER,
      x_project_id               IN       NUMBER,
      x_task_id                  IN       NUMBER,
      status                     IN OUT NOCOPY   NUMBER
   ) IS
   BEGIN
--	IF NOT gms_install.enabled THEN -- Bug 3002305
	IF NOT pa_gms_api.vert_install THEN
	   RETURN ;
	END IF ;
-- -------------------------------------------------
-- Vertical application will override the code here.
-- -------------------------------------------------
      gms_pa_api.vert_si_adj (x_expenditure_item_id,
         x_invoice_id,
         x_distribution_line_number,
         x_project_id,
         x_task_id,
         status
      );
   END vert_si_adj;

   FUNCTION is_sponsored_project (
      x_project_id               IN       NUMBER
   )
      RETURN BOOLEAN IS
      x_return                      BOOLEAN;
   BEGIN
      x_return                   := FALSE;
      IF pa_gms_api.vert_install THEN
      x_return                   := gms_pa_api.is_sponsored_project (x_project_id
           );
      END IF;
      RETURN x_return;
   END is_sponsored_project;
-- -------------------------------------------------
-- Vertical application will override the code here.
-- -------------------------------------------------
     FUNCTION vert_install   return BOOLEAN is
                x_return            BOOLEAN := FALSE ;
        BEGIN
         x_return  		:= gms_pa_api.vert_install ;
        RETURN x_return ;
     END vert_install ;

   -- ----------------------------------------------------------------------
   -- BUG: 1380464 - Net Zero SI, mixed invoice are not picked up by PA
   -- 			   Supplier invoice interface process.
   --                this is called from PAAPIMP_PKG.
   -- ----------------------------------------------------------------------
   FUNCTION vert_get_award_id (
      x_award_set_id             IN       NUMBER,
      x_invoice_id               IN       NUMBER,
      x_distribution_line_number IN       NUMBER
   )
      RETURN NUMBER IS
      l_award_id                    NUMBER;
   BEGIN
		IF NVL(x_award_set_id,0) = 0 THEN
			l_award_id := 0 ;
			return l_award_id ;
		END IF ;

--		IF gms_install.enabled THEN -- bug 3002305
		IF pa_gms_api.vert_install THEN
			l_award_id := gms_pa_api.vert_get_award_id( x_award_set_id,
								x_invoice_id,
								x_distribution_line_number ) ;
		ELSE
			l_award_id := 0 ;
		END IF ;

      RETURN nvl(l_award_id,0) ;
   END vert_get_award_id;

   -- -------------------------------------
   -- End of Bug Fixes for 1380464
   -- -------------------------------------

/* R12 Changes Start */
  PROCEDURE VERT_SET_ADJUST_ACTION(p_adjust_action IN VARCHAR2) IS
  BEGIN
      IF PA_GMS_API.VERT_INSTALL THEN
          GMS_PA_API.SET_ADJUST_ACTION(p_adjust_action);
      END IF;
  END VERT_SET_ADJUST_ACTION;

  PROCEDURE VERT_SET_PROJECT_ID
      ( p_source_project_id IN VARCHAR2
      , p_dest_project_id IN VARCHAR2) IS
  BEGIN
      IF   PA_GMS_API.VERT_INSTALL
      AND (p_source_project_id IS NOT NULL
      OR   p_dest_project_id IS NOT NULL) THEN
          GMS_PA_API.GMS_SET_PROJECT_ID(p_source_project_id, p_dest_project_id);
      END IF;
  END VERT_SET_PROJECT_ID;

  PROCEDURE VERT_SET_AWARD_ID
      ( p_source_award_id IN VARCHAR2
      , p_dest_award_id IN VARCHAR2) IS
  BEGIN
      IF   PA_GMS_API.VERT_INSTALL
      AND (p_source_award_id IS NOT NULL
      OR   p_dest_award_id IS NOT NULL) THEN
          GMS_PA_API.GMS_SET_AWARD(p_source_award_id, p_dest_award_id);
      END IF;
  END VERT_SET_AWARD_ID;

  PROCEDURE VERT_GET_SRC_DEST_AWARD_ID
      ( X_source_award_id OUT NOCOPY VARCHAR2
      , X_dest_award_id OUT NOCOPY VARCHAR2) IS
  BEGIN
      IF  PA_GMS_API.VERT_INSTALL THEN
          X_source_award_id := GMS_PA_API.SOURCE_AWARD_ID;
          X_dest_award_id := GMS_PA_API.DEST_AWARD_ID;
      END IF;
  END VERT_GET_SRC_DEST_AWARD_ID;

  FUNCTION VERT_EI_AWD_EQUALS_SRC_AWD(p_expenditure_item_id NUMBER)
  RETURN VARCHAR2 IS
  BEGIN
     IF  PA_GMS_API.VERT_INSTALL THEN
         IF  GMS_PA_API.CHECK_ADJUST_ALLOWED(p_expenditure_item_id) THEN
             RETURN 'Y';
         ELSE
             RETURN 'N';
         END IF;
     ELSE
         RETURN 'Y';
     END IF;
  END VERT_EI_AWD_EQUALS_SRC_AWD;

  FUNCTION VERT_GET_EI_AWARD_ID(p_expenditure_item_id NUMBER)
  RETURN NUMBER IS
  BEGIN
     IF  PA_GMS_API.VERT_INSTALL THEN
         RETURN GMS_PA_API.VERT_GET_EI_AWARD_ID(p_expenditure_item_id);
     ELSE
         RETURN NULL;
     END IF;
  END VERT_GET_EI_AWARD_ID;
/* R12 Changes End */


/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input and returns the award associated with
   this expenditure item.
   The function returns NULL if no award is associated with the expenditure item.
*/
  FUNCTION VERT_GET_AWARD_NUMBER(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ) RETURN VARCHAR2 IS
  BEGIN
    IF NOT PA_GMS_API.VERT_INSTALL THEN
      RETURN NULL;
    ELSE
      RETURN GMS_PA_API.VERT_GET_AWARD_NUMBER(
        p_expenditure_item_id
       );
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END VERT_GET_AWARD_NUMBER;

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
   ) RETURN VARCHAR2 IS
  BEGIN
    IF NOT PA_GMS_API.VERT_INSTALL THEN
      RETURN 'Y';
    ELSE
      RETURN GMS_PA_API.VERT_IS_AWARD_WITHIN_RANGE(
        p_expenditure_item_id
       ,p_from_award_number
       ,p_to_award_number
       );
    END IF;
  END VERT_IS_AWARD_WITHIN_RANGE;

END pa_gms_api;

/
