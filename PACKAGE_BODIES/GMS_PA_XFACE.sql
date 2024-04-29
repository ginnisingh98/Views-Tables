--------------------------------------------------------
--  DDL for Package Body GMS_PA_XFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PA_XFACE" AS
--$Header: gmsexadb.pls 115.3 2002/08/01 09:43:53 gnema ship $

-- VERIFY is a wrapper Function which is called from PAXTADJB.pll to check
-- 1. The expenditure_type is allowed for the dest_award. GMS_CHECK_EXP_TYPE() will return TRUE
--    if the exp_type is allowed for the allowability_sechdule_id of the dest_award_id

-- 2. The expenditure_item_date is less than or equal to the End_date of the dest_award. GMS_CHECK_AWARD_DATES
--    will return TRUE if the expenditure_item_date is less than or equal to the End_date of the dest_award

-- 3. Whether the Invoice distribution line in AP is Reversed out or not. GMS_CHECK_BURDEN_COST will return
--    FALSE if the query does not  find a record in AP tables which is Reversed out . In that case we will fail the record

-- ===================================================================================================================
-- This function will verify whether the project is SPONSORED PROJECT or NOT
-- ===================================================================================================================
  FUNCTION GMS_IS_SPON_PROJECT (x_project_id IN NUMBER ) RETURN BOOLEAN IS

	CURSOR c_project IS
	SELECT 'X'
	FROM pa_projects p,
	     gms_project_types gpt
        WHERE p.project_id  	=  x_project_id
	AND   p.project_type	= gpt.project_type
	AND   gpt.sponsored_flag= 'Y'  ;

	x_dummy		varchar2(1) ;
	x_return        BOOLEAN ;
	BEGIN
	  OPEN c_project ;
	   fetch c_project into x_dummy ;
	   IF c_project%FOUND then
		x_return := TRUE ;
	   ELSE
		x_return := FALSE ;
	   END IF ;
	  return (x_return ) ;
	CLOSE c_project ;
     EXCEPTION
	 WHEN OTHERS THEN
		return FALSE ;
   END GMS_IS_SPON_PROJECT ;


-- ===================================================================================================================

  FUNCTION VERIFY (x_expenditure_item_id IN NUMBER ) RETURN BOOLEAN IS

   BEGIN
	    IF
        	 GMS_IS_SPON_PROJECT (SOURCE_PROJECT_ID )  -- If the project is sponsored project then only perform other things
		 AND GMS_CHECK_AWARD_DATES(x_expenditure_item_id )  -- with in the Award_end_date , hence TRANSFER
	    	 AND GMS_CHECK_EXP_TYPE(x_expenditure_item_id ) -- This expenditure_type is allowable, hence TRANSFER
           	 AND NOT GMS_CHECK_BURDENCOST (x_expenditure_item_id ) -- This item_id is not Reversed out in AP , hence TRANSFER
	    THEN
            return FALSE  ;
           END IF;
           return TRUE;    -- Don't TRANSFER
  END VERIFY ;

-- ========================================================================================================
-- This procedure  will be called from PAXTRAPE (Expenditure Inquiry ) form when an expenditure_item is SPLIT.
-- This will insert a reversed expendtiure_item record and two new expenditure_items records into ADL table.
-- =========================================================================================================
 PROCEDURE  GMS_SPLIT (x_expenditure_item_id IN NUMBER ) IS

  adl_rec    gms_award_distributions%ROWTYPE;
   x_flag    varchar2(1);
 CURSOR rev_item(x_expenditure_item_id NUMBER ) IS
 SELECT * from pa_expenditure_items_all
 WHERE adjusted_expenditure_item_id = x_expenditure_item_id ;

 CURSOR new_item(x_expenditure_item_id NUMBER ) IS
 SELECT * from pa_expenditure_items_all
 WHERE transferred_from_exp_item_id = x_expenditure_item_id ;

 BEGIN

    FOR rev_rec IN  rev_item(x_expenditure_item_id) LOOP

  begin
  select award_id , bill_hold_flag into source_award_id ,x_flag from gms_award_distributions adl
  where adl.expenditure_item_id = x_expenditure_item_id
  and adl.document_type = 'EXP' ;
  exception
  when too_many_rows then
   null;
 end ;

       adl_rec.expenditure_item_id	 := rev_rec.expenditure_item_id;
       adl_rec.cost_distributed_flag	 := 'N';
       adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       adl_rec.task_id   		 := rev_rec.task_id;
       adl_rec.cdl_line_num              := 1;
       adl_rec.adl_line_num              := 1;
       adl_rec.distribution_value        := 100;
       adl_rec.line_type                 :='R';
       adl_rec.adl_status                := 'A';
       adl_rec.document_type             := 'EXP';
       adl_rec.billed_flag               := 'N';
       adl_rec.bill_hold_flag            := x_flag ;
       adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       adl_rec.award_id                  := source_award_id ;
       adl_rec.raw_cost			 := rev_rec.raw_cost;
       adl_rec.last_update_date    	 := rev_rec.last_update_date;
       adl_rec.creation_date      	 := rev_rec.creation_date;
       adl_rec.last_updated_by        	 := rev_rec.last_updated_by;
       adl_rec.created_by         	 := rev_rec.created_by;
       adl_rec.last_update_login   	 := rev_rec.last_update_login;
        gms_awards_dist_pkg.create_adls(adl_rec);
   END LOOP;

    FOR new_rec IN  new_item (x_expenditure_item_id) LOOP
       adl_rec.expenditure_item_id	 := new_rec.expenditure_item_id;
       adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       adl_rec.task_id   		 := new_rec.task_id;
       adl_rec.cost_distributed_flag	 := 'N';
       adl_rec.cdl_line_num              := 1;
       adl_rec.adl_line_num              := 1;
       adl_rec.distribution_value        := 100 ;
       adl_rec.line_type                 :='R';
       adl_rec.adl_status                := 'A';
       adl_rec.document_type             := 'EXP';
       adl_rec.billed_flag               := 'N';
       adl_rec.bill_hold_flag            := x_flag ;
       adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       adl_rec.award_id                  := source_award_id;
       adl_rec.raw_cost			 := new_rec.raw_cost;
       adl_rec.last_update_date    	 := new_rec.last_update_date;
       adl_rec.creation_date      	 := new_rec.creation_date;
       adl_rec.last_updated_by        	 := new_rec.last_updated_by;
       adl_rec.created_by         	 := new_rec.created_by;
       adl_rec.last_update_login   	 := new_rec.last_update_login;
        gms_awards_dist_pkg.create_adls(adl_rec);
   END LOOP;

    EXCEPTION

   when others then
  raise ;
  END GMS_SPLIT;

-- ==============================================================================================
--  GMS_CHECK_EXP_TYPE() will return TRUE
--  if the exp_type is allowed for the allowability_sechdule_id of the dest_award_id
--  This function will be called from PAXTRPAE( Expenditure_Inquiry ) while trasnferring to check
--   whether the expenditure_item is with in the award end_date.
-- ===============================================================================================

  FUNCTION GMS_CHECK_EXP_TYPE (x_expenditure_item_id IN NUMBER ) RETURN BOOLEAN IS

      CURSOR exp_type IS
      select expenditure_type
      from gms_allowable_expenditures
      where allowability_schedule_id = x_allowable_id
      and expenditure_type = x_expenditure_type;

     BEGIN
        OPEN exp_type ;
        FETCH exp_type INTO x_type ;
        IF exp_type%FOUND THEN
        return TRUE ;
        CLOSE exp_type ;
        END IF;
        return FALSE ;

	EXCEPTION
	WHEN OTHERS THEN
	RAISE;
 END GMS_CHECK_EXP_TYPE ;

-- =======================================================================================================
--    GMS_CHECK_AWARD_DATES
--    will return TRUE if the expenditure_item_date is less than or equal to the End_date of the dest_award
-- ========================================================================================================
   FUNCTION GMS_CHECK_AWARD_DATES(x_expenditure_item_id IN NUMBER ) RETURN BOOLEAN IS

      CURSOR C_AWARDS(dest_award_id IN NUMBER) IS
       select allowable_schedule_id ,end_date_active from gms_awards_all
       where award_id = dest_award_id ;

      CURSOR C_EXP(x_expenditure_item_id IN NUMBER ) IS
      select expenditure_type,expenditure_item_date
      from pa_expenditure_items_all
      where expenditure_item_id = x_expenditure_item_id;

     BEGIN

  	  FOR  awards_rec IN C_AWARDS (dest_award_id) LOOP
       		  x_allowable_id := awards_rec.allowable_schedule_id ;
        	  x_end_date     := awards_rec.end_date_active ;
	  END LOOP;

  	 FOR  exp_rec IN C_EXP (x_expenditure_item_id) LOOP
       		 x_expenditure_type := exp_rec.expenditure_type ;
       		 x_item_date        := exp_rec.expenditure_item_date ;
	 END LOOP;

	IF x_item_date <= x_end_date THEN
        return TRUE;
        END IF;
        return FALSE;

	EXCEPTION
	WHEN OTHERS THEN
	RAISE;
   END GMS_CHECK_AWARD_DATES ;

-- ========================================================================================
--    GMS_CHECK_BURDEN_COST will return
--    FALSE if the query finds a record in AP tables which is Reversed out
-- ========================================================================================
    FUNCTION GMS_CHECK_BURDENCOST (x_expenditure_item_id IN NUMBER ) RETURN BOOLEAN IS
	X_REF2		VARCHAR2(30);
	X_REF3		VARCHAR2(30);
      CURSOR C_CDL IS
        select CDL.system_reference2 ,  -- AP INVOICE_ID
	       CDL.system_reference3    -- AP DIST LINE NUM
	from  pa_cost_distribution_lines     CDL,
	      ap_invoice_distributions       ADL
        where CDL.expenditure_item_id  = X_expenditure_item_id
	and   CDL.system_reference2    = ADL.invoice_id
	and   CDL.system_reference3    = ADL.distribution_line_number
	and   ADL.attribute6          IS NULL
	and   CDL.line_num	       = 1
	and   CDL.system_reference2   IS NOT NULL
	and   CDL.system_reference3   IS NOT NULL;

	BEGIN


	OPEN c_cdl;
	fetch c_cdl into x_ref2,x_ref3;
        IF c_cdl%FOUND THEN
         RETURN TRUE ;
           -- ERROR   : NOT ALLOWED ANY ADJUSTMENTS (SPLIT, TRASFER )
        END IF;
        CLOSE c_cdl;
	RETURN FALSE;

	EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RAISE ;
	WHEN OTHERS THEN
	RAISE;
	END GMS_CHECK_BURDENCOST;

-- ==============================================================================

FUNCTION GMS_COMP_AWARDS(X_ADJUST_ACTION IN VARCHAR2 ) RETURN VARCHAR2 IS

BEGIN
 If GMS_IS_SPON_PROJECT( source_project_id ) AND SOURCE_AWARD_ID = DEST_AWARD_ID  THEN
  return 'Y';
 end if;
  RETURN 'N' ;
END GMS_COMP_AWARDS;

-- ================================================================================

PROCEDURE GMS_SET_AWARD (X_SOURCE_AWARD_ID    IN   NUMBER,
		     X_DEST_AWARD_ID      IN   NUMBER) IS

  BEGIN

    SOURCE_AWARD_ID := X_SOURCE_AWARD_ID;
    DEST_AWARD_ID   := X_DEST_AWARD_ID;

END GMS_SET_AWARD;

-- ================================================================================
PROCEDURE GMS_SET_PROJECT_ID (X_SOURCE_PROJECT_ID    IN   NUMBER,
		     X_DEST_PROJECT_ID      IN   NUMBER) IS

  BEGIN

    SOURCE_PROJECT_ID := X_SOURCE_PROJECT_ID;
    DEST_PROJECT_ID   := X_DEST_PROJECT_ID;

END GMS_SET_PROJECT_ID;

-- ======================================================================================================================
-- This proceudre is called from PAXTRANB.pls while the expenditure_ites are transferred or MassAdjusted.
-- For TRASFER x_rows will be 1 since expenditure_items are loaded into LaoadEi record by record and
-- transferred one at a time. Where as while  MassAdjusting all the expenditures_items are loaded into LoadEi at one shot
-- =======================================================================================================================

PROCEDURE GMS_ADJUST_ITEMS (X_CALLING_PROCESS IN VARCHAR2,
		            X_ROWS            IN   NUMBER ) IS

  adl_rec    gms_award_distributions%ROWTYPE;
  x_exp_item_id  NUMBER;
  x_new_item_id  NUMBER;
   x_flag        varchar2(1) ;
 CURSOR rev_item(x_exp_item_id NUMBER ) IS
 SELECT * from pa_expenditure_items_all
 WHERE adjusted_expenditure_item_id = x_exp_item_id ;

 CURSOR new_item(x_exp_item_id NUMBER ) IS
 SELECT * from pa_expenditure_items_all
 WHERE transferred_from_exp_item_id = x_exp_item_id ;

 BEGIN

 IF X_CALLING_PROCESS  IN ( 'TRANSFER') and  GMS_IS_SPON_PROJECT (SOURCE_PROJECT_ID ) THEN

  FOR i IN 1..X_ROWS LOOP

   x_exp_item_id := PA_TRANSACTIONS.TfrEiTab(i);

    begin
	  select bill_hold_flag, award_id  into x_flag, source_award_id  from gms_award_distributions
  	  where expenditure_item_id = x_exp_item_id
  	  and award_id = source_award_id
	  and document_type = 'EXP'  ;
    exception
	when others then
	 null;
    end ;
    FOR rev_rec IN  rev_item(x_exp_item_id) LOOP
       adl_rec.expenditure_item_id	 := rev_rec.expenditure_item_id;
       adl_rec.cost_distributed_flag	 := 'N';
       adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       adl_rec.task_id   		 := rev_rec.task_id;
       adl_rec.cdl_line_num              := 1;
       adl_rec.adl_line_num              := 1;
       adl_rec.distribution_value        := 100;
       adl_rec.line_type                 :='R';
       adl_rec.adl_status                := 'A';
       adl_rec.document_type             := 'EXP';
       adl_rec.billed_flag               := 'N';
       adl_rec.bill_hold_flag            := x_flag ;
       adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       adl_rec.award_id                  := SOURCE_AWARD_ID;
       adl_rec.raw_cost			 := rev_rec.raw_cost;
       adl_rec.last_update_date    	 := rev_rec.last_update_date;
       adl_rec.creation_date      	 := rev_rec.creation_date;
       adl_rec.last_updated_by        	 := rev_rec.last_updated_by;
       adl_rec.created_by         	 := rev_rec.created_by;
       adl_rec.last_update_login   	 := rev_rec.last_update_login;
        gms_awards_dist_pkg.create_adls(adl_rec);
   END LOOP;

    FOR new_rec IN  new_item (x_exp_item_id) LOOP
       adl_rec.expenditure_item_id	 := new_rec.expenditure_item_id;
       adl_rec.project_id 		 := DEST_PROJECT_ID;
       adl_rec.task_id   		 := new_rec.task_id;
       adl_rec.cost_distributed_flag	 := 'N';
       adl_rec.cdl_line_num              := 1;
       adl_rec.adl_line_num              := 1;
       adl_rec.distribution_value        := 100;
       adl_rec.line_type                 :='R';
       adl_rec.adl_status                := 'A';
       adl_rec.document_type             := 'EXP';
       adl_rec.billed_flag               := 'N';
       adl_rec.bill_hold_flag            := x_flag ;
       adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       adl_rec.award_id                  := DEST_AWARD_ID;
       adl_rec.raw_cost			 := new_rec.raw_cost;
       adl_rec.last_update_date    	 := new_rec.last_update_date;
       adl_rec.creation_date      	 := new_rec.creation_date;
       adl_rec.last_updated_by        	 := new_rec.last_updated_by;
       adl_rec.created_by         	 := new_rec.created_by;
       adl_rec.last_update_login   	 := new_rec.last_update_login;
        gms_awards_dist_pkg.create_adls(adl_rec);
   END LOOP;

  END LOOP;

  END IF;

-- These are commented out because the source project_id  is getting NULL when the TRANSFER is done for more than one record.
-- These values are set before calling SPLIT,TRANSFER and MASADJUST.

--  SOURCE_AWARD_ID := '';
--  DEST_AWARD_ID   := '';
--  SOURCE_PROJECT_ID := '';
--  DEST_PROJECT_ID   := '';

    EXCEPTION

   when others then
   RAISE;
  END GMS_ADJUST_ITEMS;
END GMS_PA_XFACE;

/
