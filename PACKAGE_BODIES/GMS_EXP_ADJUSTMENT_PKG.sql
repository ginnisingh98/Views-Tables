--------------------------------------------------------
--  DDL for Package Body GMS_EXP_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_EXP_ADJUSTMENT_PKG" AS
--$Header: gmsrevab.pls 120.1 2007/02/06 09:52:54 rshaik ship $

-- ============================================================================================================
-- This procedure will be called from PAXTREPE (Expenditure Entry form ) while an expenditure batch is Copied.
-- This will retrive all the expenditure_items for a perticular batch and insert into ADL table .
-- ============================================================================================================
  PROCEDURE GMS_EXP_COPY(X_NEW_GROUP IN VARCHAR2, X_ORG_GROUP IN VARCHAR2, P_OUTCOME IN OUT NOCOPY VARCHAR2 ) IS
     x_adl_rec     	gms_award_distributions%ROWTYPE;
     x_award_id         NUMBER ;
     x_project_id       NUMBER ;
     x_count            NUMBER ;
     x_expenditure_type VARCHAR2(30) ;
     x_task_id          NUMBER ;
     x_quantity         NUMBER ;

-- ===================================================================================================
-- This cursor verifies whether any duplicate records are there in gms_award_distributions table
-- before copying the items by comparing the exp_type,task_id and quantity of origional and new items.
-- This is done as there is no link between the new and origional item. If a duplicate record is
-- found in ADL table then this expenditure item is deleted from pa_expenditure_items_all
-- table otherwise adl is created .
-- ===================================================================================================

  CURSOR NEW_ITEMS (x_new_group VARCHAR2 ) IS
  select e1.expenditure_item_id,
         e1.expenditure_type,
	 e1.expenditure_item_date ,
         e1.task_id ,
         e1.quantity ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login
  from pa_expenditure_items_all e1
      ,pa_expenditures_all e2

    where e2.expenditure_group = x_new_group
  and   e2.expenditure_id    = e1.expenditure_id
  and   e1.expenditure_type  = x_expenditure_type
  and   e1.task_id           = x_task_id
  and   e1.quantity          = x_quantity
  and  not exists (select 'X' from gms_award_distributions gad
		  where gad.expenditure_item_id = e1.expenditure_item_id
                    and gad.adl_status = 'A'
                    and gad.document_type ='EXP'
                   )
 order by e1.expenditure_item_id asc ;


  CURSOR ORG_ITEMS (x_org_group VARCHAR2 ) IS
  select e1.expenditure_item_id,
         e1.expenditure_type,
	 e1.expenditure_item_date ,
         e1.quantity,
         e1.task_id ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login

  from pa_expenditure_items_all e1
      ,pa_expenditures_all e2
      ,pa_expenditure_groups_all e3
  where e3.expenditure_group = x_org_group
  and   e3.expenditure_group = e2.expenditure_group
  and   e2.expenditure_id    = e1.expenditure_id
  order by e1.expenditure_item_id asc;

  BEGIN

       FOR org_rec IN ORG_ITEMS (x_org_group ) LOOP

	    x_expenditure_type 	:= org_rec.expenditure_type ;
	    x_task_id   := org_rec.task_id ;
            x_quantity  := org_rec.quantity ;

    	FOR new_rec IN NEW_ITEMS (x_new_group ) LOOP

          IF NEW_ITEMS%FOUND THEN

             -- Fix starts for bug number : 1708977
                select project_id into x_project_id
		from pa_tasks
                where task_id = x_task_id ;

           IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) then
             -- Fix ends for bug number : 1708977

                  Begin
	            select  distinct(adl.project_id), adl.award_id into x_project_id , x_award_id
       		    from gms_award_distributions adl
		    where adl.expenditure_item_id = org_rec.expenditure_item_id
       		    and adl.document_type = 'EXP'
       		    and adl.adl_status = 'A'  ;
                  Exception
		  WHEN others then
                  Raise ;
		  END ;

          	gms_transactions_pub.validate_transaction (x_project_id ,
		 				     new_rec.task_id,
						     x_award_id ,
						     new_rec.expenditure_type ,
						     new_rec.expenditure_item_date ,
						     'EXP',
                                                     p_outcome ) ;

          -- ==========================================================================
          -- Here we rollback if outcome is not null . So the records inserted by PA in
          -- expenditures and ITEMS table will de deleted because of the rollback .
          -- ==========================================================================
          If p_outcome is NOT NULL THEN
             rollback ;
	      return ;
          End if;

         x_adl_rec.award_id            := x_award_id ;
         x_adl_rec.adl_line_num        := 1;
         x_adl_rec.project_id          := x_project_id ;
         x_adl_rec.task_id             := new_rec.task_id ;
         x_adl_rec.distribution_value  := 100 ;
         x_adl_rec.adl_status          := 'A' ;
         x_adl_rec.line_type           := 'R' ;
         x_adl_rec.document_type       := 'EXP' ;
         x_adl_rec.award_set_id        := gms_awards_dist_pkg.get_award_set_id;
	 x_adl_rec.expenditure_item_id := new_rec.expenditure_item_id;
         x_adl_rec.billed_flag         := 'N' ;
         x_adl_rec.last_update_date    := new_rec.last_update_date;
         x_adl_rec.creation_date       := new_rec.creation_date;
	 x_adl_rec.last_updated_by     := new_rec.last_updated_by;
         x_adl_rec.created_by          := new_rec.created_by;
	 x_adl_rec.last_update_login    := new_rec.last_update_login;

        gms_awards_dist_pkg.create_adls(x_adl_rec);
        EXIT ;       -- Fix for bug : 2642650
        -- Fix for bug number: 1708977
         END IF ; -- if for IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) Check

      ELSE

	 DELETE from pa_expenditure_items_all
	 WHERE  expenditure_item_id = new_rec.expenditure_item_id ;

    END IF ; -- End if for IF NEW_ITEMS%FOUND check

  END LOOP;  -- For New_Items cursor

  END LOOP ; -- For ORG_ITEMS cursor

    EXCEPTION
   when others then
   raise ;
 END GMS_EXP_COPY ;
-- ============================================================================================================
-- This procedure will be called from PAXTREPE (Expenditure Entry form ) while an expenditure batch is Reversed.
-- This will retrive all the expenditure_items for a perticular batch and insert into ADL table .
-- ============================================================================================================
  PROCEDURE GMS_EXP_REVERSE(X_REVERSE_GROUP IN VARCHAR2) IS
     x_adl_rec     	gms_award_distributions%ROWTYPE;
     x_award_id         NUMBER ;
     x_project_id       NUMBER ;
  CURSOR EXP_ITEMS (x_reverse_group VARCHAR2 ) IS
  select e1.expenditure_item_id,
        -- e1.project_id ,
         e1.task_id ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login ,
         e1.adjusted_expenditure_item_id

  from pa_expenditure_items_all e1
      ,pa_expenditures_all e2

    where e2.expenditure_group = x_reverse_group
     and  e2.expenditure_id = e1.expenditure_id ;
  BEGIN

    FOR rev_rec IN EXP_ITEMS (x_reverse_group ) LOOP
     -- Fix starts for bug number : 1708977
       select project_id into x_project_id
       from pa_tasks
       where task_id = rev_rec.task_id ;
     IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) then
      -- Fix ends for bug number : 1708977

      begin
       select distinct(project_id), award_id into x_project_id ,x_award_id
       from gms_award_distributions adl
       where expenditure_item_id = rev_rec.adjusted_expenditure_item_id
       	    and adl.document_type = 'EXP'
       	    and adl.adl_status = 'A'  ;
     exception
       when others then
	Raise;
     end ;
    -- Chage made for bug fix : 1708977
    -- 		  IF GMS_PA_XFACE.GMS_IS_SPON_PROJECT (x_project_id ) THEN
         x_adl_rec.award_id            := x_award_id ;
         x_adl_rec.adl_line_num        := 1;
         x_adl_rec.project_id          := x_project_id ;
         x_adl_rec.task_id             := rev_rec.task_id ;
         x_adl_rec.distribution_value  := 100 ;
         x_adl_rec.adl_status          := 'A' ;
         x_adl_rec.line_type           := 'R' ;
         x_adl_rec.document_type       := 'EXP' ;
         x_adl_rec.award_set_id        := gms_awards_dist_pkg.get_award_set_id;
	 x_adl_rec.expenditure_item_id := rev_rec.expenditure_item_id;
         x_adl_rec.billed_flag         := 'N' ;
         x_adl_rec.bill_hold_flag      := 'N' ;
         x_adl_rec.last_update_date    := rev_rec.last_update_date;
         x_adl_rec.creation_date       := rev_rec.creation_date;
	 x_adl_rec.last_updated_by     := rev_rec.last_updated_by;
         x_adl_rec.created_by          := rev_rec.created_by;
	 x_adl_rec.last_update_login    := rev_rec.last_update_login;

        gms_awards_dist_pkg.create_adls(x_adl_rec);

     END IF ;
  END LOOP;

    EXCEPTION
   when others then
   raise ;
 END GMS_EXP_REVERSE;


-- ============================================================================================================
-- This procedure will be called from GMSTRENE(Encumbrance Entry form ) while an encumbrance batch is copied.
-- This will retrive all the encumbrance_items for a perticular batch and insert into ADL table .
-- ============================================================================================================
 PROCEDURE GMS_ENC_COPY(X_NEW_GROUP IN VARCHAR2, X_ORG_GROUP IN VARCHAR2 , P_OUTCOME IN OUT NOCOPY VARCHAR2 ) IS
     x_adl_rec     	gms_award_distributions%ROWTYPE;
     x_award_id         NUMBER ;
     x_project_id       NUMBER ;
     x_count            NUMBER ;
     x_encumbrance_type VARCHAR2(30) ;
     x_task_id          NUMBER ;
     x_amount           NUMBER ;

-- ===================================================================================================
-- This cursor verifies whether any duplicate records are there in gms_award_distributions table
-- before copying the items by comparing the exp_type,task_id and quantity of origional and new items.
-- This is done as there is no link between the new and origional item. If a duplicate record is
-- found in ADL table then this encumbrance item is deleted from gms_encumbrance_items_all
-- table otherwise adl is created .
-- ===================================================================================================
  CURSOR NEW_ITEMS (x_new_group VARCHAR2 ) IS
  select e1.encumbrance_item_id,
         e1.encumbrance_type ,
         e1.encumbrance_item_date ,
         e1.task_id ,
         e1.amount ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login
  from gms_encumbrance_items_all e1
      ,gms_encumbrances_all e2

  where e2.encumbrance_group = x_new_group
  and   e2.encumbrance_id    = e1.encumbrance_id
  and   e1.encumbrance_type  = x_encumbrance_type
  and   e1.task_id           = x_task_id
  and   e1.amount            = x_amount
  and   not exists (select 'X' from gms_award_distributions gad
                    where gad.expenditure_item_id = e1.encumbrance_item_id
                      and gad.adl_status = 'A'
                      and gad.document_type ='ENC'
                   )
  order by e1.encumbrance_item_id  asc;

  CURSOR ORG_ITEMS (x_org_group VARCHAR2 ) IS
  select e1.encumbrance_item_id ,
         e1.encumbrance_type ,
         e1.encumbrance_item_date ,
         e1.amount ,
         e1.task_id ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login
  from gms_encumbrance_items_all e1
      ,gms_encumbrances_all e2
      ,gms_encumbrance_groups_all e3
  where e3.encumbrance_group = x_org_group
  and   e3.encumbrance_group = e2.encumbrance_group
  and   e2.encumbrance_id    = e1.encumbrance_id
 order by e1.encumbrance_item_id asc ;


  BEGIN

    FOR org_rec IN ORG_ITEMS (x_org_group ) LOOP

             x_encumbrance_type := org_rec.encumbrance_type ;
             x_task_id          := org_rec.task_id ;
             x_amount           := org_rec.amount ;

    FOR new_rec IN NEW_ITEMS (x_new_group ) LOOP

      IF NEW_ITEMS%FOUND THEN

             -- Fix starts for bug number : 1708977
                select project_id into x_project_id
		from pa_tasks
                where task_id = x_task_id ;

           IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) then

             -- Fix ends for bug number : 1708977

        	Begin
        	select distinct(adl.project_id) ,adl.award_id into x_project_id , x_award_id
        	from gms_award_distributions adl
        	where adl.expenditure_item_id = org_rec.encumbrance_item_id
        	and adl.document_type = 'ENC'
                and nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
                and adl.line_num_reversed is null --Bug 5726575
        	and adl.adl_status = 'A' ;

        	Exception
		WHEN others then
        	Raise ;
		END ;

        gms_transactions_pub.validate_transaction (x_project_id ,
						   new_rec.task_id ,
 						   x_award_id ,
						   new_rec.encumbrance_type ,
                                                   new_rec.encumbrance_item_date ,
						   'ENC' ,
						    p_outcome ) ;

        -- ==========================================================================
         -- Here we rollback if outcome is not null . So the records inserted by GMS in
         -- encumbrance and ITEMS table will de deleted because of the rollback .
         -- ==========================================================================

          If p_outcome is NOT NULL THEN
             rollback ;
              return ;
          End if;

         x_adl_rec.award_id            := x_award_id ;
         x_adl_rec.adl_line_num        := 1;
         x_adl_rec.project_id          := x_project_id ;
         x_adl_rec.task_id             := new_rec.task_id ;
         x_adl_rec.distribution_value  := 100 ;
         x_adl_rec.adl_status          := 'A' ;
         x_adl_rec.line_type           := 'R' ;
         x_adl_rec.cdl_line_num        := 1 ;
         x_adl_rec.document_type       := 'ENC' ;
         x_adl_rec.award_set_id        := gms_awards_dist_pkg.get_award_set_id;
	 x_adl_rec.expenditure_item_id := new_rec.encumbrance_item_id;
         x_adl_rec.billed_flag         := 'N' ;
         x_adl_rec.bill_hold_flag      := 'N' ;
         x_adl_rec.last_update_date    := new_rec.last_update_date;
         x_adl_rec.creation_date       := new_rec.creation_date;
	 x_adl_rec.last_updated_by     := new_rec.last_updated_by;
         x_adl_rec.created_by          := new_rec.created_by;
	 x_adl_rec.last_update_login    := new_rec.last_update_login;

        gms_awards_dist_pkg.create_adls(x_adl_rec);
        EXIT ; -- Fix for bug : 2642650

         END IF ; -- if for IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) Check

  End if ;
  END LOOP;
  END LOOP;
    EXCEPTION
   when others then
   raise ;
 END GMS_ENC_COPY;

-- ============================================================================================================
-- This procedure will be called from GMSTRENE(Encumbrance Entry form ) while an encumbrance batch is Reversed.
-- This will retrive all the encumbrance_items for a perticular batch and insert into ADL table .
-- ============================================================================================================
 PROCEDURE GMS_ENC_REVERSE(X_NEW_GROUP IN VARCHAR2) IS
     x_adl_rec     	gms_award_distributions%ROWTYPE;
     x_award_id         NUMBER ;
     x_project_id       NUMBER ;
  CURSOR ENC_ITEMS (x_new_group VARCHAR2 ) IS
  select e1.encumbrance_item_id,
         e1.task_id ,
         e1.creation_date ,
         e1.created_by ,
         e1.last_update_date ,
         e1.last_updated_by ,
         e1.last_update_login ,
         e1.adjusted_encumbrance_item_id

  from gms_encumbrance_items_all e1
      ,gms_encumbrances_all e2

  where e2.encumbrance_group = x_new_group
  and   e2.encumbrance_id    = e1.encumbrance_id;


  BEGIN

    FOR rev_rec IN ENC_ITEMS (x_new_group ) LOOP

     -- Fix starts for bug number : 1708977
       select project_id into x_project_id
       from pa_tasks
       where task_id = rev_rec.task_id ;

     IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) then

      -- Fix ends for bug number : 1708977
        Begin
	 select  distinct(adl.project_id), adl.award_id into x_project_id , x_award_id
      		 from gms_award_distributions adl
  	where expenditure_item_id = rev_rec.adjusted_encumbrance_item_id
        	and   adl.document_type ='ENC'
                and   nvl(adl.reversed_flag, 'N') = 'N' --Bug 5726575
                and   adl.line_num_reversed is null --Bug 5726575
       	    	and   adl.adl_status = 'A'  ;

        Exception
	WHEN others then
        Raise ;
	END ;

         x_adl_rec.award_id            := x_award_id ;
         x_adl_rec.adl_line_num        := 1;
         x_adl_rec.project_id          := x_project_id ;
         x_adl_rec.task_id             := rev_rec.task_id ;
         x_adl_rec.distribution_value  := 100 ;
         x_adl_rec.adl_status          := 'A' ;
         x_adl_rec.line_type           := 'R' ;
         x_adl_rec.cdl_line_num        := 1 ;
         x_adl_rec.document_type       := 'ENC' ;
         x_adl_rec.award_set_id        := gms_awards_dist_pkg.get_award_set_id;
	 x_adl_rec.expenditure_item_id := rev_rec.encumbrance_item_id;
         x_adl_rec.billed_flag         := 'N' ;
         x_adl_rec.bill_hold_flag      := 'N' ;
         x_adl_rec.last_update_date    := rev_rec.last_update_date;
         x_adl_rec.creation_date       := rev_rec.creation_date;
	 x_adl_rec.last_updated_by     := rev_rec.last_updated_by;
         x_adl_rec.created_by          := rev_rec.created_by;
	 x_adl_rec.last_update_login    := rev_rec.last_update_login;

        gms_awards_dist_pkg.create_adls(x_adl_rec);

         END IF ; -- if for IF GMS_PA_API.IS_SPONSORED_PROJECT(x_project_id ) Check

  END LOOP;
    EXCEPTION
   when others then
   raise ;
 END GMS_ENC_REVERSE;

END GMS_EXP_ADJUSTMENT_PKG;

/
