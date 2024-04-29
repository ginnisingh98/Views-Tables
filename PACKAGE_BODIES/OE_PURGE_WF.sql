--------------------------------------------------------
--  DDL for Package Body OE_PURGE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PURGE_WF" AS
  /* $Header: OEXVPWFB.pls 120.0.12010000.1 2009/06/24 07:59:27 spothula noship $ */
  g_purge_count      NUMBER :=0;
  g_commit_frequency NUMBER :=500;
  g_age              NUMBER :=0;
  g_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  /*----------------------------------------------------------------------------------
  Procedure:   Purge_Orphan_Errors
  Description: This procedure is created to purge the orhan error flows. That is, the
  error flowswhose parent information is missing, or the parent is no longer
  in error. This API will come into picture, only if item type passed is
  OMERROR or ALL and the attempt_to_close parameter is yes. This API will
  abort and immediately purge all such error flows.
  -------------------------------------------------------------------------------------*/
PROCEDURE Purge_Orphan_Errors
  (
    p_item_key IN VARCHAR2 DEFAULT NULL )
               IS
  l_errors_tbl wf_tbl_type;
  CURSOR errors
  IS
    SELECT e.item_type,
      e.item_key
    FROM wf_items e
    WHERE ((e.item_type     = 'WFERROR'
    AND e.parent_item_type IN ('OEOH','OEOL','OENH','OEBH'))
    OR e.item_type          ='OMERROR')
    AND e.end_date         IS NULL
    AND NOT EXISTS
      (SELECT 1
      FROM wf_item_activity_statuses s
      WHERE s.item_type     = e.parent_item_type
      AND s.item_key        = e.parent_item_key
      AND s.activity_status = 'ERROR'
      );
  CURSOR specific_error(c_item_key VARCHAR2)
  IS
    SELECT e.item_type,
      e.item_key
    FROM wf_items e
    WHERE e.item_type='OMERROR'
    AND e.end_date  IS NULL
    AND e.item_key   =c_item_key
    AND NOT EXISTS
      (SELECT 1
      FROM wf_item_activity_statuses s
      WHERE s.item_type     = e.parent_item_type
      AND s.item_key        = e.parent_item_key
      AND s.activity_status = 'ERROR'
      );
  /*came up with the above cursor, to honour the attempt to close parameter, when
  item type is passed as 'OMERROR' and a specific error key is passed*/
BEGIN
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Entering the procedure oe_purge_wf.purge_orphan_errors',1);
  END IF ;
  IF p_item_key     IS NULL THEN
    IF g_debug_level > 0 THEN
      oe_debug_pub.add( 'Item key is not passed. Fetching all the orphan error flows.',2);
    END IF ;
    OPEN errors;
    LOOP
      FETCH errors BULK COLLECT INTO l_errors_tbl LIMIT g_commit_frequency;
      -- EXIT WHEN errors%NOTFOUND ;
      IF l_errors_tbl.count>0 THEN
        FOR i             IN l_errors_tbl.first .. l_errors_tbl.last
        LOOP
          BEGIN
            IF g_debug_level > 0 THEN
              oe_debug_pub.add( 'Setting the error parent to null and aborting the flow',5);
            END IF ;
            WF_ITEM.Set_Item_Parent(l_errors_tbl(i).ITEM_TYPE,l_errors_tbl(i).ITEM_KEY,NULL,NULL,NULL);
            wf_engine.abortprocess(itemtype =>l_errors_tbl(i).ITEM_TYPE, itemkey=>l_errors_tbl(i).item_key);
          EXCEPTION
          WHEN OTHERS THEN
            UPDATE wf_items
            SET end_date   = sysdate
            WHERE item_type=l_errors_tbl(i).ITEM_TYPE
            AND item_key   =l_errors_tbl(i).item_key;
          END;
          IF g_debug_level > 0 THEN
            oe_debug_pub.add( 'Purging the error flow for item_type and item_key'||l_errors_tbl(i).ITEM_TYPE||'and'||l_errors_tbl(i).ITEM_KEY,5);
          END IF ;
          wf_purge.items(itemtype => l_errors_tbl(i).ITEM_TYPE, itemkey => l_errors_tbl(i).ITEM_KEY, docommit => FALSE, force=>TRUE);
          g_purge_count:=g_purge_count+1;
        END LOOP ;
      END IF ;
      l_errors_tbl.DELETE ;
      EXIT
    WHEN errors%NOTFOUND ;
    END LOOP ;
    CLOSE errors;
  ELSE
    IF g_debug_level > 0 THEN
      oe_debug_pub.add( 'Item key is passed. Fetching the specific error flow for key:'||p_item_key,2);
    END IF ;
    OPEN specific_error(p_item_key);
    LOOP
      FETCH specific_error BULK COLLECT INTO l_errors_tbl LIMIT g_commit_frequency;
      -- EXIT WHEN errors%NOTFOUND ;
      IF l_errors_tbl.count>0 THEN
        FOR i             IN l_errors_tbl.first .. l_errors_tbl.last
        LOOP
          BEGIN
            IF g_debug_level > 0 THEN
              oe_debug_pub.add( 'Setting the error parent to null and aborting the flow for the specific key',5);
            END IF ;
            WF_ITEM.Set_Item_Parent(l_errors_tbl(i).ITEM_TYPE,l_errors_tbl(i).ITEM_KEY,NULL,NULL,NULL);
            wf_engine.abortprocess(itemtype =>l_errors_tbl(i).ITEM_TYPE, itemkey=>l_errors_tbl(i).item_key);
          EXCEPTION
          WHEN OTHERS THEN
            UPDATE wf_items
            SET end_date   = sysdate
            WHERE item_type=l_errors_tbl(i).ITEM_TYPE
            AND item_key   =l_errors_tbl(i).item_key;
          END;
          IF g_debug_level > 0 THEN
            oe_debug_pub.add( 'Purging the error flow for item_type and item_key'||l_errors_tbl(i).ITEM_TYPE||'and'||l_errors_tbl(i).ITEM_KEY,5);
          END IF ;
          wf_purge.items(itemtype => l_errors_tbl(i).ITEM_TYPE, itemkey => l_errors_tbl(i).ITEM_KEY, docommit => FALSE, force=>TRUE);
          g_purge_count:=g_purge_count+1;
        END LOOP ;
      END IF ;
      l_errors_tbl.DELETE ;
      EXIT
    WHEN specific_error%NOTFOUND ;
    END LOOP ;
    CLOSE specific_error;
  END IF ;
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Exiting oe_purge_wf.purge_orphan_errors',1);
  END IF ;
EXCEPTION
WHEN OTHERS THEN
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'In others exception of oe_purge_wf.purge_orphan_errors',1);
  END IF ;
  oe_debug_pub.add( sqlerrm);
  l_errors_tbl.DELETE ;
  IF errors%isopen THEN
    CLOSE errors;
  END IF;
  IF specific_error%isopen THEN
    CLOSE specific_error;
  END IF;
END purge_orphan_errors;
/*----------------------------------------------------------------------------------
Procedure:   Attempt_To_Close
Description: This procedure is created for order headers only. It comes into picture
only if the item type passed in 'OEOH' or 'ALL', and the attempt_to_close
parameter is 'yes'. This API will first abort and purge all the error
flows associated with the order header. It will then retry the close_wait_
for_l activity for the headers.
-------------------------------------------------------------------------------------*/
PROCEDURE attempt_to_close
  (
    p_item_key IN VARCHAR2 DEFAULT NULL )
               IS
  l_wf_details_tbl wf_details_tbl_type;
  l_error_tbl wf_tbl_type;
  l_result      VARCHAR2(30);
  g_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  CURSOR TO_CLOSE
  IS
    SELECT P.INSTANCE_LABEL,
      WAS.ITEM_KEY,
      H.ORDER_NUMBER,
      H.ORG_ID
    FROM WF_ITEM_ACTIVITY_STATUSES WAS,
      WF_PROCESS_ACTIVITIES P,
      OE_ORDER_HEADERS_ALL H
    WHERE TO_NUMBER(WAS.ITEM_KEY) = H.HEADER_ID
    AND WAS.PROCESS_ACTIVITY      = P.INSTANCE_ID
    AND P.ACTIVITY_ITEM_TYPE      = 'OEOH'
    AND P.ACTIVITY_NAME           = 'CLOSE_WAIT_FOR_L'
    AND WAS.ACTIVITY_STATUS       = 'NOTIFIED'
    AND WAS.ITEM_TYPE             = 'OEOH'
    AND NOT EXISTS
      (SELECT 1
      FROM OE_ORDER_LINES_ALL
      WHERE HEADER_ID = H.HEADER_ID
      AND OPEN_FLAG   = 'Y'
      );
  CURSOR CLOSE_SPECIFIC(c_item_key VARCHAR2 )
  IS
    SELECT P.INSTANCE_LABEL,
      WAS.ITEM_KEY,
      H.ORDER_NUMBER,
      H.ORG_ID
    FROM WF_ITEM_ACTIVITY_STATUSES WAS,
      WF_PROCESS_ACTIVITIES P,
      OE_ORDER_HEADERS_ALL H
    WHERE TO_NUMBER(WAS.ITEM_KEY) = H.HEADER_ID
    AND WAS.PROCESS_ACTIVITY      = P.INSTANCE_ID
    AND P.ACTIVITY_ITEM_TYPE      = 'OEOH'
    AND P.ACTIVITY_NAME           = 'CLOSE_WAIT_FOR_L'
    AND WAS.ACTIVITY_STATUS       = 'NOTIFIED'
    AND WAS.item_key              = c_item_key
    AND WAS.ITEM_TYPE             = 'OEOH'
    AND NOT EXISTS
      (SELECT 1
      FROM OE_ORDER_LINES_ALL
      WHERE HEADER_ID = H.HEADER_ID
      AND OPEN_FLAG   = 'Y'
      );
  CURSOR ERRORS (c_header_id NUMBER)
  IS
    SELECT I.ITEM_TYPE,
      I.ITEM_KEY
    FROM WF_ITEMS I
    WHERE I.ITEM_TYPE     IN ('OMERROR','WFERROR')
    AND I.PARENT_ITEM_TYPE = 'OEOH'
    AND I.PARENT_ITEM_KEY  = TO_CHAR(c_header_id)
    AND I.END_DATE        IS NULL FOR UPDATE NOWAIT;
BEGIN
  IF g_debug_level > 0 THEN
    oe_debug_pub.ADD('Entering oe_purge_wf.attempt_to_close',1 ) ;
  END IF;
  IF p_item_key     IS NOT NULL THEN
    IF g_debug_level > 0 THEN
      oe_debug_pub.ADD('Header id is passed. Fetching the specific header.',1 ) ;
    END IF;
    OPEN close_specific(p_item_key);
    LOOP
      FETCH close_specific BULK COLLECT
      INTO l_wf_details_tbl LIMIT g_commit_frequency;
      --EXIT WHEN to_close%NOTFOUND ;
      IF l_wf_details_tbl.Count >0 THEN
        FOR i                  IN l_wf_details_tbl.first .. l_wf_details_tbl.last
        LOOP
          BEGIN
            IF g_debug_level > 0 THEN
              oe_debug_pub.ADD('Fetching the error flows associated with the header:'||p_item_key,2 ) ;
            END IF;
            OPEN ERRORS(To_Number(l_wf_details_tbl(i).item_key));
            LOOP
              FETCH ERRORS BULK COLLECT INTO l_error_tbl LIMIT g_commit_frequency;
              --EXIT WHEN ERRORS%NOTFOUND ;
              IF l_error_tbl.Count>0 THEN
                FOR j            IN l_error_tbl.first .. l_error_tbl.last
                LOOP
                  BEGIN
                    IF g_debug_level > 0 THEN
                      oe_debug_pub.ADD('Clearing the parent info from the error and aborting the error flow.',1 ) ;
                    END IF;
                    WF_ITEM.Set_Item_Parent(l_error_tbl(j).ITEM_TYPE,l_error_tbl(j).ITEM_KEY,NULL,NULL,NULL);
                    WF_ENGINE.ABORTPROCESS(ITEMTYPE =>l_error_tbl(j).ITEM_TYPE, ITEMKEY=>l_error_tbl(j).ITEM_KEY);
                  EXCEPTION
                  WHEN OTHERS THEN
                    UPDATE WF_ITEMS
                    SET END_DATE   = SYSDATE
                    WHERE item_type=l_error_tbl(j).ITEM_TYPE
                    AND item_key   =l_error_tbl(j).ITEM_KEY;
                  END;
                  IF g_debug_level > 0 THEN
                    oe_debug_pub.ADD('Purging the error item_type and error item_key'||l_error_tbl(j).ITEM_TYPE||'and'||l_error_tbl(j).ITEM_KEY,1 ) ;
                  END IF;
                  WF_PURGE.ITEMS(ITEMTYPE =>l_error_tbl(j).ITEM_TYPE, ITEMKEY=>l_error_tbl(j).ITEM_KEY, DOCOMMIT=>FALSE, FORCE=>TRUE);
                  g_purge_count:=g_purge_count+1;
                END LOOP; --looping in the error table
                l_error_tbl.DELETE ;
              END IF;
              EXIT
            WHEN ERRORS%NOTFOUND ;
            END LOOP ; --error cursor
            CLOSE errors;
            IF g_debug_level > 0 THEN
              oe_debug_pub.ADD('Done with the error flows. Setting the context.',2 ) ;
            END IF;
            BEGIN
              OE_Standard_WF.OEOH_SELECTOR (p_itemtype => 'OEOH' ,p_itemkey => l_wf_details_tbl(i).item_key ,p_actid => 12345 ,p_funcmode => 'SET_CTX' ,p_result => l_result );
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_CLIENT_INFO.SET_ORG_CONTEXT(l_wf_details_tbl(i).org_id);
              FND_PROFILE.PUT('ORG_ID', TO_CHAR(l_wf_details_tbl(i).org_id));
            END;
            IF g_debug_level > 0 THEN
              oe_debug_pub.ADD('Retrying the close_wait_for_l activity',2 ) ;
            END IF;
            WF_ENGINE.HANDLEERROR('OEOH', l_wf_details_tbl(i).item_key, l_wf_details_tbl(i).INSTANCE_LABEL, 'RETRY',NULL);
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;
        END LOOP ; --specific cusror
        l_wf_details_tbl.DELETE ;
      END IF;
      EXIT
    WHEN close_specific%NOTFOUND ;
    END LOOP ;
    CLOSE close_specific;
  ELSE
    IF g_debug_level > 0 THEN
      oe_debug_pub.ADD('Header id is not passed. Fetching all the stuck headers.',1 ) ;
    END IF;
    OPEN to_close;
    LOOP
      FETCH to_close BULK COLLECT INTO l_wf_details_tbl LIMIT g_commit_frequency;
      --EXIT WHEN to_close%NOTFOUND ;
      IF l_wf_details_tbl.Count >0 THEN
        FOR i                  IN l_wf_details_tbl.first .. l_wf_details_tbl.last
        LOOP
        IF g_debug_level        > 0 THEN
          oe_debug_pub.ADD('Getting the error flows associated with the specific headers.',2 ) ;
        END IF;

          BEGIN
            OPEN ERRORS(To_Number(l_wf_details_tbl(i).item_key));
            LOOP
              FETCH ERRORS BULK COLLECT INTO l_error_tbl LIMIT g_commit_frequency;
              --EXIT WHEN ERRORS%NOTFOUND ;
              IF l_error_tbl.Count>0 THEN
                FOR j            IN l_error_tbl.first .. l_error_tbl.last
                LOOP
                  BEGIN
                    IF g_debug_level > 0 THEN
                      oe_debug_pub.ADD('Removing the parent reference and aborting the error flow',1 ) ;
                    END IF;
                    WF_ITEM.Set_Item_Parent(l_error_tbl(j).ITEM_TYPE,l_error_tbl(j).ITEM_KEY,NULL,NULL,NULL);
                    WF_ENGINE.ABORTPROCESS(ITEMTYPE =>l_error_tbl(j).ITEM_TYPE, ITEMKEY=>l_error_tbl(j).ITEM_KEY);
                  EXCEPTION
                  WHEN OTHERS THEN
                    UPDATE WF_ITEMS
                    SET END_DATE   = SYSDATE
                    WHERE item_type=l_error_tbl(j).ITEM_TYPE
                    AND item_key   =l_error_tbl(j).ITEM_KEY;
                  END;
                  IF g_debug_level > 0 THEN
                    oe_debug_pub.ADD('Purging the error item type and error item key'||l_error_tbl(j).ITEM_TYPE||'and'||l_error_tbl(j).ITEM_KEY,3) ;
                  END IF;
                  WF_PURGE.ITEMS(ITEMTYPE =>l_error_tbl(j).ITEM_TYPE, ITEMKEY=>l_error_tbl(j).ITEM_KEY, DOCOMMIT=>FALSE, FORCE=>TRUE);
                  g_purge_count:=g_purge_count+1;
                END LOOP; --error table count
                l_error_tbl.DELETE ;
              END IF;
              EXIT
            WHEN ERRORS%NOTFOUND ;
            END LOOP ; --error cursor fetch.
            CLOSE errors;
            BEGIN
              IF g_debug_level > 0 THEN
                oe_debug_pub.ADD('Done with error flows. Setting the context for the header',2) ;
              END IF;
              OE_Standard_WF.OEOH_SELECTOR (p_itemtype => 'OEOH' ,p_itemkey => l_wf_details_tbl(i).item_key ,p_actid => 12345 ,p_funcmode => 'SET_CTX' ,p_result => l_result );
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              FND_CLIENT_INFO.SET_ORG_CONTEXT(l_wf_details_tbl(i).org_id);
              FND_PROFILE.PUT('ORG_ID', TO_CHAR(l_wf_details_tbl(i).org_id));
            END;
            IF g_debug_level > 0 THEN
              oe_debug_pub.ADD('Retrying close_wait_for_l activity for the header',2) ;
            END IF;
            WF_ENGINE.HANDLEERROR('OEOH', l_wf_details_tbl(i).item_key, l_wf_details_tbl(i).INSTANCE_LABEL, 'RETRY',NULL);
          EXCEPTION
          WHEN OTHERS THEN
            NULL;
          END;
        END LOOP ; --to close cursor fetch
        l_wf_details_tbl.DELETE ;
      END IF;
      EXIT
    WHEN to_close%NOTFOUND ;
    END LOOP ;
    CLOSE to_close;
  END IF ; --item key check
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Exiting oe_purge_wf.attempt_to_close',1 ) ;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  l_wf_details_tbl.DELETE ;
  l_error_tbl.DELETE ;
  IF to_close%ISOPEN THEN
    CLOSE to_close;
  END IF ;
  IF errors%ISOPEN THEN
    CLOSE errors;
  END IF ;
  IF close_specific%isopen THEN
    CLOSE close_specific;
  END IF ;
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( SQLERRM ) ;
  END IF;
END attempt_to_close ;
/*----------------------------------------------------------------------------------
Procedure:   Purge_Item_Type
Description: This procedure is created to purge the closed workflows of a specific
item type.
-------------------------------------------------------------------------------------*/
PROCEDURE purge_item_type
  (
    p_item_type                 IN VARCHAR2 )
                                IS
  g_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_purge_tbl wf_tbl_type;
  CURSOR to_purge
  IS
    SELECT item_type,
      item_key
    FROM wf_items
    WHERE item_type=p_item_type
    AND end_date  <= (SYSDATE-g_age);
BEGIN
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Entering oe_purge_wf.purge_item_type:'||p_item_type ,1) ;
  END IF;
  OPEN to_purge ;
  LOOP
    FETCH to_purge BULK COLLECT INTO l_purge_tbl limit g_commit_frequency;
    --EXIT WHEN to_purge%NOTFOUND ;
    IF l_purge_tbl.COUNT>0 THEN
      FOR i            IN l_purge_tbl.first .. l_purge_tbl.last
      LOOP
        oe_debug_pub.add( l_purge_tbl(i).item_key);
        BEGIN
	  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Before purging the item_key:'||l_purge_tbl(i).item_key ,1) ;
  END IF;
          WF_PURGE.ITEMS(ITEMTYPE =>l_purge_tbl(i).item_type, ITEMKEY=>l_purge_tbl(i).item_key, DOCOMMIT=>FALSE, FORCE=>TRUE);
          g_purge_count:=g_purge_count+1;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END ;
      END LOOP ;
    END IF ;
    COMMIT ;
    l_purge_tbl.DELETE ;
    EXIT
  WHEN to_purge%NOTFOUND ;
  END LOOP ;
  CLOSE to_purge ;
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Exiting oe_purge_wf.purge_item_type',1 ) ;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  oe_debug_pub.add(FND_FILE.OUTPUT,sqlerrm);
  l_purge_tbl.DELETE ;
  IF to_purge%isopen THEN
    CLOSE to_purge;
  END IF ;
END purge_item_type;
/*----------------------------------------------------------------------------------
Procedure:   Purge_OM_Flows
Description: This is the main API of the package, which will be called from the con
current "Purge Order management Workflow" concurrent program.
-------------------------------------------------------------------------------------*/
PROCEDURE purge_om_flows
  (
    errbuf OUT NOCOPY  VARCHAR2 ,
    retcode OUT NOCOPY VARCHAR2 ,
    p_item_type                 IN VARCHAR2 DEFAULT NULL ,
    p_item_key                  IN VARCHAR2 DEFAULT NULL ,
    p_age                       IN NUMBER DEFAULT 0 ,
    p_attempt_to_close          IN VARCHAR2 DEFAULT 'N' ,
    p_commit_frequency          IN NUMBER DEFAULT 500 )
                                IS
  l_purge_tbl wf_tbl_type;
  l_end_date DATE ;
  l_item_type VARCHAR2(8);
  CURSOR purge_all
  IS
    SELECT item_type,
      item_key
    FROM wf_items
    WHERE end_date <= (SYSDATE-g_age)
    AND item_type            IN ('OEOH','OEOL','OENH','OEBH','OMERROR');
BEGIN
  IF g_debug_level > 0 THEN
    oe_debug_pub.add( 'Entering oe_purge_wf.purge_om_flows',1) ;
    oe_debug_pub.add( 'Item type passed is:'||p_item_type,1);
    oe_debug_pub.add( 'Item key passed is:'||p_item_key,1);
    oe_debug_pub.add( 'Attempt to close passed is:'||p_attempt_to_close,1);
    oe_debug_pub.add( 'Elapsed days After closure passed is:'||p_age,1);
    oe_debug_pub.add( 'Commit frequency passed is:'||p_commit_frequency,1);
  END IF;
  l_item_type  := p_item_type;
  IF l_item_type='ALL' THEN
    l_item_type:= NULL ;
  END IF ;
  g_commit_frequency:=NVL(p_commit_frequency,500);
  g_age             :=NVL(p_age,0);
  Retcode           := '0';
  Errbuf            := '';
  IF l_item_type    IS NOT NULL THEN
    IF p_item_key   IS NOT NULL THEN
      BEGIN
        SELECT end_date
        INTO l_end_date
        FROM wf_items
        WHERE item_type=l_item_type
        AND item_key   =p_item_key;
      EXCEPTION
      WHEN No_Data_Found THEN
        NULL ;
      END ;
      IF l_end_date IS NOT NULL AND l_end_date <= (sysdate-g_age) THEN
        /*Added the AND condition, just to ensure that a workflow will not get purged,
        if its age is small, even though it is end dated and both item type and item key
        are passed.*/
        IF g_debug_level > 0 THEN
          oe_debug_pub.add( 'end date is not null');
        END IF ;
        WF_PURGE.ITEMS(ITEMTYPE =>l_item_type, ITEMKEY=>p_item_key, DOCOMMIT=>FALSE, FORCE=>TRUE);
        g_purge_count:=g_purge_count+1;
      ELSIF  l_end_date IS NULL THEN

        IF p_attempt_to_close='Y'THEN

	  IF g_debug_level   > 0 THEN
            oe_debug_pub.add( 'Before calling attempt to close');
          END IF ;
          IF l_item_type = 'OEOH' THEN
            attempt_to_close(p_item_key);

          ELSIF l_item_type='OMERROR' THEN
            purge_orphan_errors(p_item_key);
	  END IF ;
          COMMIT;

	  BEGIN
            SELECT end_date
            INTO l_end_date
            FROM wf_items
            WHERE item_type=l_item_type
            AND item_key   =p_item_key;
          EXCEPTION
          WHEN No_Data_Found THEN
            NULL;
          END ;

          IF l_end_date     IS NOT NULL THEN
            IF g_debug_level > 0 THEN
              oe_debug_pub.add( 'Before Purging');
            END IF ;
            WF_PURGE.ITEMS(ITEMTYPE =>l_item_type, ITEMKEY=>p_item_key, DOCOMMIT=>FALSE, FORCE=>TRUE);
            g_purge_count:=g_purge_count+1;
          END IF ;
        END IF ;
      END IF ;
    ELSIF l_item_type      ='OEOH' THEN
      IF p_attempt_to_close='Y' THEN
        IF g_debug_level   > 0 THEN
          oe_debug_pub.add( 'Before calling attempt to close');
        END IF ;
        attempt_to_close;
        COMMIT;
      END IF ;
      IF g_debug_level > 0 THEN
        oe_debug_pub.add( 'Before purging');
      END IF ;
      purge_item_type(l_item_type);
    ELSIF l_item_type      ='OMERROR' THEN
      IF p_attempt_to_close='Y' THEN
        IF g_debug_level   > 0 THEN
          oe_debug_pub.add( 'Before calling Purge orphan errors');
        END IF ;
        purge_orphan_errors;
        COMMIT ;
      END IF;
      IF g_debug_level > 0 THEN
        oe_debug_pub.add( 'Before calling purge item type');
      END IF ;
      purge_item_type(l_item_type);
    ELSE
      IF g_debug_level > 0 THEN
        oe_debug_pub.add( 'item type passed is neither OMERROR nor OEOH');
      END IF ;
      purge_item_type(l_item_type);
    END IF ;                     --end item key is not null
  ELSIF l_item_type IS NULL THEN --item type is null
    IF g_debug_level > 0 THEN
      oe_debug_pub.add( 'item type passed is all item types');
    END IF ;
    IF p_item_key IS NOT NULL THEN
      fnd_file.put_line(FND_FILE.OUTPUT,'Item type cannot be null when item key is not null. ' ) ;
      IF g_debug_level > 0 THEN
        oe_debug_pub.add( 'Item type cannot be null when item key is not null. ' ) ;
      END IF;
    ELSE
      IF p_attempt_to_close='Y' THEN
        attempt_to_close;
        purge_orphan_errors;
        COMMIT ;
      END IF ;
      OPEN purge_all;
      LOOP
        FETCH purge_all BULK COLLECT INTO l_purge_tbl limit p_commit_frequency;
        --EXIT WHEN purge_all%NOTFOUND ;
        IF l_purge_tbl.Count>0 THEN
          FOR i            IN l_purge_tbl.first .. l_purge_tbl.last
          LOOP
            BEGIN
              IF g_debug_level > 0 THEN
                oe_debug_pub.add( 'Before purging for item_type and item_key'||l_purge_tbl(i).item_type||','||l_purge_tbl(i).item_key );
              END IF ;
              WF_PURGE.ITEMS(ITEMTYPE =>l_purge_tbl(i).item_type, ITEMKEY=>l_purge_tbl(i).item_key, DOCOMMIT=>FALSE, FORCE=>TRUE);
              g_purge_count:=g_purge_count+1;
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END ;
          END LOOP ;
          COMMIT ;
          l_purge_tbl.DELETE ;
        END IF;
        EXIT
      WHEN purge_all%NOTFOUND ;
      END LOOP ;
      CLOSE purge_all;
    END IF;
  END IF;
  errbuf  := '';
  retcode := '0';
  fnd_file.put_line(FND_FILE.OUTPUT,'Number of workflow items Purged is:'|| g_purge_count);
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
WHEN OTHERS THEN
  g_age             :=0;
  g_commit_frequency:=500;
  oe_debug_pub.add(FND_FILE.OUTPUT,sqlerrm);
  retcode := 2;
  errbuf  := sqlerrm;
  l_purge_tbl.DELETE ;
  IF purge_all%isopen THEN
    CLOSE purge_all;
  END IF ;
END purge_om_flows;
END OE_PURGE_WF;

/
