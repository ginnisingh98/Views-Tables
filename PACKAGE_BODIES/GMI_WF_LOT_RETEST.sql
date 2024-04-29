--------------------------------------------------------
--  DDL for Package Body GMI_WF_LOT_RETEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_WF_LOT_RETEST" AS
/* $Header: gmiltrtb.pls 115.4 2003/10/16 15:22:28 hsaleeb ship $ */

   PROCEDURE init_wf (
      /* called via trigger on ic_lots_mst  */
      p_lot_id        IN   ic_lots_mst.lot_id%TYPE ,
      p_lot_no        IN   ic_lots_mst.lot_no%TYPE ,
      p_sublot_no     IN   ic_lots_mst.sublot_no%TYPE  ,
      p_retest_date   IN   ic_lots_mst.retest_date%TYPE ,
      p_item_id       IN   ic_lots_mst.item_id%TYPE ,
      p_created_by    IN   ic_lots_mst.created_by%TYPE
   )

   IS
      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'GMWLOTEX';

      /* since two WF processes exist with the GMWLOTEX WF Item,
      prefix ITEMKEY with 'RT' to differentiate the Retest Process */
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE  :=  'RT' || TO_CHAR(p_lot_id) ;

      /* number of days before lot retest date to send WF notification
	  value is fetched from table gmwlotrt_ctl
      if not found in gmwlotrt_ctl, default is 7 days */
      l_retest_interval NUMBER(3);
      l_retest_interval_from_tab NUMBER(3);
      l_default_retest_interval NUMBER(3) := 7;
      /* make sure that process runs with background engine
      to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
      the 'magic value' to use for this is -1 */
      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;

      l_retest_notify_date   DATE ;
      l_wf_start_date        DATE ;

      l_item_no   ic_item_mst.item_no%TYPE ;
      l_item_desc1   ic_item_mst.item_desc1%TYPE ;
      l_dualum_ind   ic_item_mst.dualum_ind%TYPE ;
      l_item_um   ic_item_mst.item_um%TYPE ;
      l_item_um2   ic_item_mst.item_um2%TYPE ;
      c_whse_item_id ic_item_mst.whse_item_id%TYPE;
      c_item_id      ic_item_mst.item_id%TYPE;
      l_performer_name  FND_USER.USER_NAME%TYPE ;
      l_performer_display_name   FND_USER.DESCRIPTION%TYPE ;

      l_role_name           sy_wf_item_roles.retest_role_name%TYPE ;
      l_role_display_name   sy_wf_item_roles.retest_role_display_name%TYPE ;

      l_WorkflowProcess   VARCHAR2(30) := 'LOT_RETEST_PROC';

      l_errname      VARCHAR2(30);
      l_errmsg      VARCHAR2(2000);

      l_errstack   VARCHAR2(32000);
      l_sqlcode    NUMBER ;


      wf_item_already_exists   EXCEPTION ;
      --BEGIN BUG#2134597 PR
      l_status                          VARCHAR2 (8);
      l_result                          VARCHAR2 (30);
      --END BUG#2134597
   CURSOR c_whse_item_role(c_whse_item_id NUMBER) is
                          ( SELECT  retest_role_name,retest_role_display_name,NVL(lot_retest_note,0)
         		    FROM    sy_wf_item_roles
         		    WHERE   whse_item_id = c_whse_item_id);
      CURSOR c_item_role(c_item_id NUMBER) is
                          ( SELECT  retest_role_name,retest_role_display_name,NVL(lot_retest_note,0)
         		    FROM    sy_wf_item_roles
         		    WHERE   item_id = c_item_id);

      CURSOR c_whse_item(c_item_id NUMBER) is
                          ( SELECT whse_item_id
                            FROM ic_item_mst
			    WHERE item_id = c_item_id);
   BEGIN
      SELECT sysdate
      INTO   l_wf_start_date
      FROM   dual;

      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = p_created_by ;

      SELECT item_no , item_desc1 ,item_um ,item_um2 , dualum_ind
      INTO   l_item_no ,l_item_desc1 ,l_item_um ,l_item_um2 ,l_dualum_ind
      FROM   ic_item_mst
      WHERE  item_id = p_item_id ;

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
          WF_CORE.CONTEXT ('gm_wf_lot_retest', 'init_wf', l_itemtype, l_itemkey, p_lot_no, p_sublot_no) ;
          WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);
      END;
      /*END BUG#2134597*/

      BEGIN
         WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
            itemkey => l_itemkey,
            process => l_WorkflowProcess);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RAISE wf_item_already_exists ;
      END ;

      WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
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
         aname => 'RETEST_DATE',
         avalue => p_retest_date);

      /* fetch notification target of this WF for this item
      find notification target of this WF for this item */
             c_item_id:=p_item_id;
             OPEN c_item_role(c_item_id);
             FETCH c_item_role INTO l_role_name,l_role_display_name,l_retest_interval_from_tab;
             IF c_item_role%NOTFOUND THEN
                LOOP
                  OPEN c_whse_item(c_item_id);
                  FETCH c_whse_item INTO c_whse_item_id;
                  IF c_whse_item%FOUND THEN
                        OPEN c_whse_item_role(c_whse_item_id);
                        FETCH c_whse_item_role INTO l_role_name,l_role_display_name,l_retest_interval_from_tab;
                        IF c_whse_item_role%NOTFOUND THEN
                           IF c_whse_item_id <> c_item_id THEN
                              c_item_id:=c_whse_item_id;
                              close c_whse_item_role;
                           ELSE
                              l_role_name:=NULL;
                              l_retest_interval_from_tab:=0;
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

      IF l_role_name IS NULL THEN
            /* no notification target found for this item
            so default to previously-selected FND_USER values */
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


                IF l_retest_interval_from_tab <> 0 THEN
                   l_retest_interval:= l_retest_interval_from_tab;
                ELSE

               	   IF (FND_PROFILE.DEFINED ('WF$RETEST_INTERVAL')) THEN
        	      l_retest_interval := FND_PROFILE.VALUE ('WF$RETEST_INTERVAL');
        	   END IF;
                   IF l_retest_interval IS NULL THEN
           	      l_retest_interval := l_default_retest_interval;
        	   END IF;
                END IF;
      l_retest_notify_date := p_retest_date - l_retest_interval ;

      IF (l_retest_notify_date < l_wf_start_date) THEN
         l_retest_notify_date := l_wf_start_date ;
      END IF ;

      WF_ENGINE.SETITEMATTRDATE (itemtype => l_itemtype,
            itemkey => l_itemkey,
            aname => 'RETEST_NOTIFY_DATE',
            avalue => l_retest_notify_date);

      WF_ENGINE.SETITEMATTRDATE (itemtype => l_itemtype,
            itemkey => l_itemkey,
            aname => 'RETEST_NOTIFY_TIME',
            avalue => l_retest_notify_date ) ;


      WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
            itemkey => l_itemkey);



   EXCEPTION

      WHEN wf_item_already_exists THEN
        null;

      WHEN OTHERS THEN

         WF_CORE.CONTEXT ('gm_wf_lot_retest', 'init_wf',l_itemtype,l_itemkey,p_lot_no,p_sublot_no) ;
         WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);

         IF (
               (l_errname IS NOT NULL)
            AND
               (SQLCODE <> 0)
         ) THEN
            l_errname := TO_CHAR(SQLCODE);
            l_errmsg  := SQLERRM(-SQLCODE);
         END IF ;

   END init_wf;

   PROCEDURE verify_retest (
      /* procedure to confirm lot expiration called via Workflow
      input/output parameters conform to WF standard (see WF FAQ)*/
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

      l_lot_id ic_lots_mst.lot_id%TYPE := TO_NUMBER(LTRIM(p_itemkey,'RT')) ;
      l_lot_no      ic_lots_mst.lot_no%TYPE ;
      l_sublot_no   ic_lots_mst.sublot_no%TYPE ;

      l_sqlcode NUMBER;
      l_sqlerrm VARCHAR2(512);
      l_errname VARCHAR2(30);
      l_errstack VARCHAR2(32000);

      l_continue_execution BOOLEAN := TRUE ;


   BEGIN

      IF (p_funcmode = 'RUN') THEN

         SELECT  COUNT(*)
         INTO    l_count_lots_mst
         FROM    ic_lots_mst
         WHERE   lot_id = l_lot_id
         AND     delete_mark = 0 ;

         IF (l_count_lots_mst <> 1) THEN
            p_resultout := 'COMPLETE:LOTDEL' ;
            l_continue_execution := FALSE ;
         END IF ;

         IF l_continue_execution THEN

               SELECT  nvl(SUM(loct_onhand),0) , nvl(SUM(loct_onhand2),0)
               INTO    l_sum_loct_onhand, l_sum_loct_onhand2
               FROM    ic_loct_inv
               WHERE   lot_id = l_lot_id;
            IF (
                  ( ( l_sum_loct_onhand + l_sum_loct_onhand2 ) = 0 )
            )THEN
               p_resultout := 'COMPLETE:ZERO' ;
            ELSE
               p_resultout := 'COMPLETE:INVEXIST';
            END IF ;

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
         l_lot_no := WF_ENGINE.GETITEMATTRTEXT (p_itemtype,
            p_itemkey,
            'LOT_NO');

         WF_ENGINE.SETITEMATTRTEXT (itemtype => p_itemtype,
            itemkey => p_itemkey,
            aname => 'ERRMSG',
            avalue => 'Bad p_funcmode passed to ' ||
         'the workflow lot retest ' ||
         'verify_retest process for lot ' || l_lot_no ||
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
            'the workflow lot retest ' ||
            'verify_retest process for lot ' || l_lot_no ||
            'sublot ' || l_sublot_no ||
            '.  Message text: ' || l_sqlerrm);

         p_resultout := 'ERROR:VERERR' ;

   END verify_retest ;

END gmi_wf_lot_retest ;

/
