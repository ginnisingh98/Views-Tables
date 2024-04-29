--------------------------------------------------------
--  DDL for Package Body GMI_WF_LOT_CM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_WF_LOT_CM" AS
/* $Header: gmiltcmb.pls 120.1 2005/10/03 12:09:47 jsrivast noship $ */

   PROCEDURE init_wf IS

      CURSOR ic_lots_mst_cursor IS
         SELECT  lot_id, lot_no , sublot_no ,expire_date ,
                 retest_date , item_id , created_by
         FROM    ic_lots_mst
         WHERE   delete_mark = 0 AND inactive_ind = 0
         FOR UPDATE; -- table is NOT updated, see NOTES section above

      l_lot_ctl             ic_item_mst.lot_ctl%TYPE ;
      l_grade_ctl           ic_item_mst.grade_ctl%TYPE ;


      l_date_at_start       DATE ;
      l_notify_date         DATE ;


      l_retest_interval             NUMBER(3);
      l_expiry_interval             NUMBER(3);
      l_retest_interval_from_tab    NUMBER(3);
      l_expiry_interval_from_tab    NUMBER(3);
      l_default_retest_interval     NUMBER(3) := 7;
      l_default_expiry_interval     NUMBER(3) := 7;

      l_date_now            DATE ;

   BEGIN

      SELECT SYSDATE  INTO l_date_at_start FROM  DUAL ;


	IF (FND_PROFILE.DEFINED ('WF$RETEST_INTERVAL')) THEN
      	    l_retest_interval := FND_PROFILE.VALUE ('WF$RETEST_INTERVAL');
        END IF;

	IF l_retest_interval = NULL THEN
           l_retest_interval := l_default_retest_interval;
        END IF;

	IF (FND_PROFILE.DEFINED ('WF$EXPIRY_INTERVAL')) THEN
      	    l_expiry_interval := FND_PROFILE.VALUE ('WF$EXPIRY_INTERVAL');
        END IF;

	IF l_expiry_interval = NULL THEN
           l_expiry_interval := l_default_expiry_interval;
        END IF;

      FOR ic_lots_mst_record IN ic_lots_mst_cursor
      LOOP

         SELECT  lot_ctl,grade_ctl
         INTO    l_lot_ctl,l_grade_ctl
         FROM    ic_item_mst
         WHERE   item_id = ic_lots_mst_record.item_id
         AND     delete_mark = 0 ;


         IF (l_lot_ctl = 1) and (l_grade_ctl = 1) THEN


                SELECT nvl(lot_retest_note,0),nvl(lot_expiry_note,0)
                INTO   l_retest_interval_from_tab, l_expiry_interval_from_tab
                FROM   sy_wf_item_roles
                WHERE   item_id = ic_lots_mst_record.item_id;

                IF l_retest_interval_from_tab <> 0   then
                   l_retest_interval:= l_retest_interval_from_tab;
                END IF;
                IF l_expiry_interval_from_tab <> 0   then
                   l_expiry_interval:= l_expiry_interval_from_tab;
                END IF;


         	IF ( ic_lots_mst_record.retest_date IS NOT NULL ) THEN
                     l_notify_date := ( ic_lots_mst_record.retest_date - l_retest_interval ) ;
       		    IF ( l_date_at_start >= l_notify_date ) THEN
		        gmi_wf_lot_retest.init_wf (
               		ic_lots_mst_record.lot_id ,
	                  ic_lots_mst_record.lot_no ,
                  	ic_lots_mst_record.sublot_no ,
                  	ic_lots_mst_record.retest_date ,
                  	ic_lots_mst_record.item_id ,
                  	ic_lots_mst_record.created_by);

            	    END IF ;

		END IF;

         	IF ( ic_lots_mst_record.expire_date IS NOT NULL ) THEN
            	     l_notify_date := ( ic_lots_mst_record.expire_date - l_expiry_interval ) ;

	            IF ( l_date_at_start >= l_notify_date ) THEN

        	        gmi_wf_lot_expiry.init_wf (
                	  ic_lots_mst_record.lot_id ,
                  	  ic_lots_mst_record.lot_no ,
                  	  ic_lots_mst_record.sublot_no ,
                  	  ic_lots_mst_record.expire_date ,
                  	  ic_lots_mst_record.item_id ,
                  	  ic_lots_mst_record.created_by);
                     END IF ;

         	END IF ;

         END IF ;

	 COMMIT ;

      END LOOP ;

   END init_wf;

END gmi_wf_lot_cm;

/
