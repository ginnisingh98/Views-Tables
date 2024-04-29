--------------------------------------------------------
--  DDL for Package Body GMI_WF_LOT_EXPIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_WF_LOT_EXPIRY" AS
/* $Header: gmiltexb.pls 115.4 2003/10/16 15:20:41 hsaleeb ship $ */

   PROCEDURE init_wf (
      /* called via trigger on ic_lots_mst */
      p_lot_id        IN   ic_lots_mst.lot_id%TYPE ,
      p_lot_no        IN   ic_lots_mst.lot_no%TYPE ,
      p_sublot_no     IN   ic_lots_mst.sublot_no%TYPE  ,
      p_expire_date   IN   ic_lots_mst.expire_date%TYPE ,
      p_item_id       IN   ic_lots_mst.item_id%TYPE ,
      p_created_by    IN   ic_lots_mst.created_by%TYPE
   )

   IS

      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'GMWLOTEX';

      /* since two WF processes exist with the GMWLOTEX WF Item,
      prefix ITEMKEY with 'EX' to differentiate the Expiry Process */
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE  :=  'EX' || TO_CHAR(p_lot_id) ;

      l_expiry_interval NUMBER(3) ;
      l_expiry_interval_from_tab NUMBER(3);
      l_default_expiry_interval NUMBER(3) :=7;
      /* make sure that process runs with background engine
      to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
      the 'magic value' to use for this is -1 */
      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;

      l_expire_notify_date   DATE ;
      l_wf_start_date        DATE ;

      l_item_no      ic_item_mst.item_no%TYPE ;
      l_item_desc1   ic_item_mst.item_desc1%TYPE ;
      l_dualum_ind   ic_item_mst.dualum_ind%TYPE ;
      l_item_um      ic_item_mst.item_um%TYPE ;
      l_item_um2     ic_item_mst.item_um2%TYPE ;
      c_whse_item_id ic_item_mst.whse_item_id%TYPE;
      c_item_id      ic_item_mst.item_id%TYPE;

      l_errname      VARCHAR2(30);
      l_errmsg       VARCHAR2(2000);

      l_errstack   VARCHAR2(32000);
      l_sqlcode    NUMBER ;
      l_performer_name  WF_ROLES.NAME%TYPE ;
      l_performer_display_name   WF_ROLES.DISPLAY_NAME%TYPE ;

      l_role_name           sy_wf_item_roles.expiry_role_name%TYPE ;
      l_role_display_name   sy_wf_item_roles.expiry_role_display_name%TYPE ;

      l_WorkflowProcess   VARCHAR2(30) := 'LOT_EXPIRY_PROC';

      wf_item_already_exists   EXCEPTION ;
      --BEGIN BUG#2134597 PR
      l_status                          VARCHAR2 (8);
      l_result                          VARCHAR2 (30);
      --END BUG#2134597
      CURSOR c_whse_item_role(c_whse_item_id NUMBER) is
                          ( SELECT  expiry_role_name,expiry_role_display_name,NVL(lot_expiry_note,0)
         		    FROM    sy_wf_item_roles
         		    WHERE   whse_item_id = c_whse_item_id);
      CURSOR c_item_role(c_item_id NUMBER) is
                          ( SELECT  expiry_role_name,expiry_role_display_name,NVL(lot_expiry_note,0)
         		    FROM    sy_wf_item_roles
         		    WHERE   item_id = c_item_id);

      CURSOR c_whse_item(c_item_id NUMBER) is
                          ( SELECT whse_item_id
                            FROM ic_item_mst
			    WHERE item_id = c_item_id);

   BEGIN
      /* set the workflow start date to date now */
      SELECT sysdate INTO l_wf_start_date FROM dual;

      /* get values to be stored into the workflow item */
      SELECT  USER_NAME, DESCRIPTION
      INTO    l_performer_name,l_performer_display_name
      FROM    FND_USER
      WHERE   USER_ID = p_created_by ;


      SELECT  item_no , item_desc1 , item_um ,item_um2 , dualum_ind
      INTO    l_item_no ,l_item_desc1 , l_item_um , l_item_um2 ,  l_dualum_ind
      FROM    ic_item_mst
      WHERE   item_id = p_item_id ;

      /*BEGIN BUG#2134597 Praveen Reddy*/
      /*Check if the workflow data exists and remove the same for the itemtype and itemkey
        combination */
      BEGIN
         IF (wf_item.item_exist (l_itemtype, l_itemkey)) THEN
            /* Check the status of the root activity */
            wf_item_activity_status.root_status (l_itemtype, l_itemkey, l_status, l_result);
            /* If it is not completed then abort the process */
            IF (l_status <> 'COMPLETE')THEN
               wf_engine.abortprocess (itemtype=> l_itemtype, itemkey=> l_itemkey, process=> l_workflowprocess);
            END IF;
            /* Purge the workflow data for workflow key */
            wf_purge.total (itemtype=> l_itemtype, itemkey=> l_itemkey, docommit=> FALSE);
         END IF;
          EXCEPTION
          WHEN OTHERS THEN
          WF_CORE.CONTEXT ('gm_wf_lot_expiry', 'init_wf', l_itemtype, l_itemkey, p_lot_no, p_sublot_no) ;
          WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);
      END;
      /*END BUG#2134597*/

      BEGIN
         /* create the process */
         WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess) ;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RAISE wf_item_already_exists ;
      END ;

      /* make sure that process runs with background engine */
      WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      /* set the item attributes */
      WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'LOT_ID',
         avalue => p_lot_id);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'LOT_NO',
         avalue => p_lot_no);

      WF_ENGINE.SETITEMATTRTEXT (itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'SUBLOT_NO',
         avalue => p_sublot_no);

      WF_ENGINE.SETITEMATTRDATE (itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'EXPIRE_DATE',
         avalue => p_expire_date);

      /* find notification target of this WF for this item */
             c_item_id:=p_item_id;
             OPEN c_item_role(c_item_id);
             FETCH c_item_role INTO l_role_name,l_role_display_name,l_expiry_interval_from_tab;
             IF c_item_role%NOTFOUND THEN
                LOOP
                  OPEN c_whse_item(c_item_id);
                  FETCH c_whse_item INTO c_whse_item_id;
                  IF c_whse_item%FOUND THEN
                        OPEN c_whse_item_role(c_whse_item_id);
                        FETCH c_whse_item_role INTO l_role_name,l_role_display_name,l_expiry_interval_from_tab;
                        IF c_whse_item_role%NOTFOUND THEN
                           IF c_whse_item_id <> c_item_id THEN
                              c_item_id:=c_whse_item_id;
                              close c_whse_item_role;
                           ELSE
                              l_role_name:=NULL;
                              l_expiry_interval_from_tab:=0;
                              close c_whse_item;
                              close c_whse_item_role;
			      EXIT;
                           END IF;
                        ELSE
                           close c_whse_item;
                           close c_whse_item_role;
                           EXIT;
                        END IF;
                   END IF;
                   close c_whse_item;
                  END LOOP;
              END IF;
              close c_item_role;
         IF l_role_name is NULL THEN
               WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
               itemkey => l_itemkey,
               aname => 'PERNAME',
               avalue => l_performer_name);
               WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
               itemkey => l_itemkey,
               aname => 'PERDISP',
               avalue => l_performer_display_name);

 	      /*Added FROM_ROLE attribute for BLAF standard */
	      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
               itemkey => l_itemkey,
               aname => '#FROM_ROLE',
               avalue => l_performer_name) ;
        ELSE
        	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         	itemkey => l_itemkey,
         	aname => 'PERNAME',
         	avalue => l_role_name) ;

         	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
            	itemkey => l_itemkey,
            	aname => 'PERDISP',
            	avalue => l_role_display_name) ;

 	       /*Added FROM_ROLE attribute for BLAF standard */
	       WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
        	itemkey => l_itemkey,
                aname => '#FROM_ROLE',
                avalue => l_role_name) ;
        END IF;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'ITEM_NO',
         avalue => l_item_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'ITEM_DESC1',
         avalue => l_item_desc1);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'ITEM_UM',
         avalue => l_item_um);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'ITEM_UM2',
         avalue => l_item_um2);

      WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'DUALUM_IND',
         avalue => l_dualum_ind);

      WF_ENGINE.SETITEMATTRDATE(itemtype => l_itemtype,
         itemkey => l_itemkey,
         aname => 'WF_START_DATE',
         avalue => l_wf_start_date) ;

/* Setting the number of days */

                IF l_expiry_interval_from_tab <> 0   then
                   l_expiry_interval:= l_expiry_interval_from_tab;
                ELSE
      		    /* Getting the WF  expiry Notification Interval */
      		   IF (FND_PROFILE.DEFINED ('WF$EXPIRY_INTERVAL')) THEN
      		       l_expiry_interval := FND_PROFILE.VALUE ('WF$EXPIRY_INTERVAL');
        	   END IF;
                   IF l_expiry_interval IS NULL THEN
           	      l_expiry_interval := l_default_expiry_interval;
        	   END IF;
                END IF;


      /* set the notification date and time */
      l_expire_notify_date := p_expire_date - l_expiry_interval ;

      IF (l_expire_notify_date < l_wf_start_date) THEN
         l_expire_notify_date := l_wf_start_date ;
      END IF ;

      WF_ENGINE.SETITEMATTRDATE (itemtype => l_itemtype,
            itemkey => l_itemkey,
            aname => 'EXPIRE_NOTIFY_DATE',
            avalue => l_expire_notify_date);

      WF_ENGINE.SETITEMATTRDATE (itemtype => l_itemtype,
            itemkey => l_itemkey,
            aname => 'EXPIRE_NOTIFY_TIME',
            avalue => l_expire_notify_date ) ;

      /* start the Workflow process */

      WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
            itemkey => l_itemkey);

  EXCEPTION

      WHEN wf_item_already_exists THEN
      Null;
      WHEN OTHERS THEN

         WF_CORE.CONTEXT ('gm_wf_lot_expiry',
            'init_wf',
            l_itemtype,
            l_itemkey,
            p_lot_no,
            p_sublot_no) ;
           WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);

    END init_wf;

   PROCEDURE verify_expiry (
      /* procedure to confirm lot expiration called via Workflow
      input/output parameters conform to WF standard (see WF FAQ) */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   )
   IS
      l_count_lots_mst     NUMBER := 0;
      l_sum_loct_onhand    ic_loct_inv.loct_onhand%TYPE    :=   0 ;
      l_sum_loct_onhand2   ic_loct_inv.loct_onhand2%TYPE   :=   0 ;

      l_lot_id ic_lots_mst.lot_id%TYPE := TO_NUMBER(LTRIM(p_itemkey, 'EX')) ;
      l_lot_no    ic_lots_mst.lot_no%TYPE ;
      l_sublot_no ic_lots_mst.sublot_no%TYPE ;

      l_sqlcode NUMBER;
      l_sqlerrm VARCHAR2(512);
      l_errname VARCHAR2(30);
      l_errstack VARCHAR2(32000);

      l_continue_execution BOOLEAN := TRUE ;

      l_date_now            DATE ;

   BEGIN
       IF (p_funcmode = 'RUN') THEN

         SELECT    COUNT(*)
         INTO      l_count_lots_mst
         FROM      ic_lots_mst
         WHERE     lot_id = l_lot_id
         AND       delete_mark = 0 ;

         IF (l_count_lots_mst <> 1) THEN
            p_resultout := 'COMPLETE:LOTDEL' ;
            l_continue_execution := FALSE ;
         END IF ;

         IF l_continue_execution THEN

            /* find out quantity we have on hand */
               SELECT nvl(SUM(loct_onhand),0) ,  nvl(SUM(loct_onhand2),0)
               INTO   l_sum_loct_onhand , l_sum_loct_onhand2
               FROM   ic_loct_inv
               WHERE  lot_id = l_lot_id
               AND    delete_mark = 0 ;

              IF (
                  /* no rows found in ic_loct_inv
                  quantities total zero */
                  ( l_sum_loct_onhand + l_sum_loct_onhand2 ) = 0
            ) THEN
               p_resultout := 'COMPLETE:ZERO' ;
            ELSE
               p_resultout := 'COMPLETE:INVEXIST';
            END IF ;

            /* save inventory quantities in WF item attributes */
            WF_ENGINE.SETITEMATTRNUMBER (itemtype => p_itemtype,
               itemkey => p_itemkey,
               aname => 'QUANTITY',
               avalue => l_sum_loct_onhand) ;
            WF_ENGINE.SETITEMATTRNUMBER (itemtype => p_itemtype,
               itemkey => p_itemkey,
               aname => 'QUANTITY2',
               avalue => l_sum_loct_onhand2) ;

         END IF ;

      ELSIF (p_funcmode = 'CANCEL') THEN
         p_resultout := 'COMPLETE' ;

      ELSIF (p_funcmode = 'TIMEOUT') THEN
         p_resultout := 'COMPLETE' ;

      ELSE
         WF_ENGINE.SETITEMATTRTEXT (itemtype => p_itemtype,
            itemkey => p_itemkey,
            aname => 'ERRMSG',
            avalue => 'Bad p_funcmode passed to ' ||
         'the workflow lot expiry ' ||
         'verify_expiry process for lot ' || l_lot_no ||
         'sublot ' || l_sublot_no ||
         'p_funcmode value = '|| p_funcmode || ' .') ;
         p_resultout := 'COMPLETE:VERERR' ;
      END IF ;

EXCEPTION

      WHEN OTHERS THEN

         l_sqlcode := SQLCODE;
         l_sqlerrm := SQLERRM(-l_sqlcode);
         l_lot_no := WF_ENGINE.GETITEMATTRTEXT (p_itemtype,
            p_itemkey,
            'LOT_NO');

         l_sublot_no := WF_ENGINE.GETITEMATTRTEXT (p_itemtype,
            p_itemkey,
            'SUBLOT_NO');

         WF_ENGINE.SETITEMATTRTEXT (itemtype => p_itemtype,
            itemkey => p_itemkey,
            aname => 'ERRMSG',
            avalue => 'A database error occurred in ' ||
            'the workflow lot expiry ' ||
            'process for lot ' || l_lot_no ||
            'sublot ' || l_sublot_no ||
            '.  Message text: ' || l_sqlerrm);

         p_resultout := 'ERROR:VERERR' ;

   END verify_expiry;

END gmi_wf_lot_expiry;

/
