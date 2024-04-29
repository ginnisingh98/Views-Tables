--------------------------------------------------------
--  DDL for Package Body POA_EUL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EUL_UTILS" AS
/* $Header: POAEULB.pls 115.10 2003/04/30 22:50:24 jhou ship $ */

 g_errbuf               VARCHAR2(2000) := NULL;
 g_retcode              VARCHAR2(200)  := NULL;

 g_eulOwner             VARCHAR2(30);
 g_EulBA_ID             NUMBER(10);
 g_EulBA_NAME           VARCHAR2(100);
 g_DiscoVersion         VARCHAR2(30);

 TYPE g_FolderNamesTable is TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
 g_FolderNames  g_FolderNamesTable;

 G_EUL_OWNER_DOES_NOT_EXIST          EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_EUL_OWNER_DOES_NOT_EXIST, -942);

 G_BUSINESS_AREA_DOES_NOT_EXIST      EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_BUSINESS_AREA_DOES_NOT_EXIST, 100);

/******************************************************************************
 Procedure InitBusArea3i
******************************************************************************/

   PROCEDURE InitBusArea3i (pBusAreaName     IN      VARCHAR2) IS

       l_stmt               VARCHAR2(1000) := NULL;

      BEGIN

          l_stmt := 'SELECT ba.ba_id,  '||
                    '       ba.ba_name '||
                    'FROM  '||g_EulOwner||'.EUL_BUSINESS_AREAS ba '||
                    'WHERE  ba.ba_name = :p_ba';

          edw_log.put_line('Procedure initBusAreas3i');
          edw_log.put_line('Going to execute statement:');
          edw_log.put_line(l_stmt);

          EXECUTE IMMEDIATE l_stmt INTO g_EulBA_ID, g_eulba_name using pBusAreaName;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_EulBA_Name := pBusAreaName;
         g_errbuf:=sqlerrm;
         g_retcode:=sqlcode;
         raise G_BUSINESS_AREA_DOES_NOT_EXIST;
      WHEN OTHERS THEN
         g_errbuf:=sqlerrm;
         g_retcode:=sqlcode;
         if g_retcode = '-942' then
           edw_log.put_line('*** Table: ' || g_EulOwner ||
                            '.EUL_BUSINESS_AREAS does not exist***');
           edw_log.put_line('Check EUL ('|| g_EulOwner ||
                            ') and EUL version (DISCO3I)');
           raise G_EUL_OWNER_DOES_NOT_EXIST;
           else
             raise;
         end if;
   END InitBusArea3i;


/******************************************************************************
 Procedure InitBusArea4i
******************************************************************************/

   PROCEDURE InitBusArea4i (pBusAreaName     IN      VARCHAR2) IS

       l_stmt               VARCHAR2(1000) := NULL;

      BEGIN

          l_stmt := 'SELECT ba.ba_id,  '||
                    '       ba.ba_name '||
                    'FROM  '||g_EulOwner||'.EUL4_BAS ba '||
                    'WHERE  ba.ba_name = :p_ba';

          edw_log.put_line('Procedure initBusAreas4i');
          edw_log.put_line('Going to execute statement:');
          edw_log.put_line(l_stmt);

          EXECUTE IMMEDIATE l_stmt INTO g_EulBA_ID, g_eulba_name using pBusAreaName;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_EulBA_Name := pBusAreaName;
         g_errbuf:=sqlerrm;
         g_retcode:=sqlcode;
         raise G_BUSINESS_AREA_DOES_NOT_EXIST;
      WHEN OTHERS THEN
         g_errbuf:=sqlerrm;
         g_retcode:=sqlcode;
         if g_retcode = '-942' then
           edw_log.put_line('*** Table: ' || g_EulOwner ||
                            '.EUL4_BAS does not exist***');
           edw_log.put_line('Check EUL ('|| g_EulOwner ||
                            ') and EUL version (DISCO4I)');
           raise G_EUL_OWNER_DOES_NOT_EXIST;
           else
             raise;
         end if;
   END InitBusArea4i;

/******************************************************************************
 Procedure hideFolder3i
******************************************************************************/
   PROCEDURE hideFolder3i(pFolderName IN VARCHAR2)
   IS

   l_stmt VARCHAR2(1000);

   BEGIN

     l_stmt :=
        'UPDATE ' || g_EulOwner || '.eul_objs obj '||
        'SET    obj.obj_hidden = 1 '||
        'WHERE  obj.obj_name = :pFolderName ' ||
        '  AND  obj.obj_type = ''SOBJ''' ||
        '  AND  EXISTS (select 1 from  ' || g_EulOwner || '.eul_ba_obj_links boj' ||
        '               where boj.BOL_BA_ID = :EulBA_ID' ||
        '                 and boj.BOL_OBJ_ID = obj.OBJ_ID)';

        EXECUTE IMMEDIATE l_stmt using pfoldername, g_EulBA_ID;


    EXCEPTION
    WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      raise;

   END hideFolder3i;


/******************************************************************************
 Procedure hideFolder4i
******************************************************************************/
   PROCEDURE hideFolder4i (pFolderName IN VARCHAR2)
   IS

   l_stmt VARCHAR2(1000);

   BEGIN

     l_stmt :=
        'UPDATE ' || g_EulOwner || '.eul4_objs obj '||
        'SET    obj.obj_hidden = 1 '||
        'WHERE  obj.obj_name = :pFolderName ' ||
        '  AND  obj.obj_type = ''SOBJ''' ||
        '  AND  EXISTS (select 1 from  ' || g_EulOwner || '.eul4_ba_obj_links boj' ||
        '               where boj.BOL_BA_ID = :EulBA_ID' ||
        '                 and boj.BOL_OBJ_ID = obj.OBJ_ID)';

        EXECUTE IMMEDIATE l_stmt using pfoldername, g_EulBA_ID;

    EXCEPTION
    WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      raise;

   END hideFolder4i;

/******************************************************************************
 Procedure hideUserAttributes3i
 This is for bug 1806629 and 1798665
******************************************************************************/
   PROCEDURE hideUserAttributes3i
   IS

    l_stmt VARCHAR2(1000);

   BEGIN

     l_stmt :=
        'UPDATE ' || g_EulOwner || '.eul_expressions exp '||
        'SET    exp.it_hidden = 1 '||
        'WHERE (exp.it_ext_column like ''%USER_ATTRIBUTE%''  OR ' ||
        '       exp.it_ext_column like ''USER_FK__KEY%''     OR ' ||
        '       exp.it_ext_column like ''USER_MEASURE%'') '       ||
        '  AND  EXISTS (select 1 from  ' || g_EulOwner || '.eul_ba_obj_links boj' ||
        '               where boj.BOL_BA_ID = :EulBA_ID ' ||
        '                 and boj.BOL_OBJ_ID = exp.ite_obj_id)';

        EXECUTE IMMEDIATE l_stmt using g_EulBA_ID;


    EXCEPTION
    WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      raise;

   END hideUserAttributes3i;


/******************************************************************************
 Procedure hideUserAttributes4i
 This is for bug 1806629 and 1798665
******************************************************************************/
   PROCEDURE hideUserAttributes4i
   IS

    l_stmt VARCHAR2(1000);

   BEGIN

     l_stmt :=
        'UPDATE ' || g_EulOwner || '.eul4_expressions exp '||
        'SET    exp.it_hidden = 1 '||
        'WHERE (exp.it_ext_column like ''%USER_ATTRIBUTE%''  OR ' ||
        '       exp.it_ext_column like ''USER_FK__KEY%''     OR ' ||
        '       exp.it_ext_column like ''USER_MEASURE%'') '       ||
        '  AND  EXISTS (select 1 from  ' || g_EulOwner || '.eul4_ba_obj_links boj' ||
        '               where boj.BOL_BA_ID = :EulBA_ID' ||
        '                 and boj.BOL_OBJ_ID = exp.it_obj_id)';

        EXECUTE IMMEDIATE l_stmt using g_EulBA_ID;


    EXCEPTION
    WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      raise;

   END hideUserAttributes4i;


/******************************************************************************
 Procedure EULMain
******************************************************************************/

   PROCEDURE EULMain (Errbuf           IN OUT NOCOPY VARCHAR2,
                      Retcode          IN OUT NOCOPY VARCHAR2,
                      pEulOwnerName    IN     VARCHAR2,
                      pBusAreaName     IN     VARCHAR2,
                      pDiscoVersion    IN     VARCHAR2)
   IS

     l_stmt           VARCHAR2(2000) := NULL;
     l_index          BINARY_INTEGER;

   BEGIN

     g_FolderNames (1)   := 'Lookup Dimension: Acceptance Required';
     g_FolderNames (2)   := 'Lookup Dimension: Accrued';
     g_FolderNames (3)   := 'Lookup Dimension: Allow Substitute Receipts';
     g_FolderNames (4)   := 'Lookup Dimension: Approved';
     g_FolderNames (5)   := 'Lookup Dimension: Approved Supplier';
     g_FolderNames (6)   := 'Lookup Dimension: Canceled';
     g_FolderNames (7)   := 'Lookup Dimension: Confirmed';
     g_FolderNames (8)   := 'Lookup Dimension: Contract in Effect';
     g_FolderNames (9)   := 'Lookup Dimension: Contract Type';
     g_FolderNames (10)  := 'Lookup Dimension: Custom Measure';
     g_FolderNames (11)  := 'Lookup Dimension: Confirming Order';
     g_FolderNames (12)  := 'Lookup Dimension: Destination Type';
     g_FolderNames (13)  := 'Lookup Dimension: Distribution Encumbered';
     g_FolderNames (14)  := 'Lookup Dimension: Document Type';
     g_FolderNames (15)  := 'Lookup Dimension: Freight On Board Term';
     g_FolderNames (16)  := 'Lookup Dimension: Freight Term';
     g_FolderNames (17)  := 'Lookup Dimension: Frozen';
     g_FolderNames (18)  := 'Lookup Dimension: Line Closed';
     g_FolderNames (19)  := 'Lookup Dimension: Negotiated By Preparer';
     g_FolderNames (20)  := 'Lookup Dimension: Online Requisition';
     g_FolderNames (21)  := 'Lookup Dimension: Parent Transaction Type';
     g_FolderNames (22)  := 'Lookup Dimension: Price Break';
     g_FolderNames (23)  := 'Lookup Dimension: Price Type';
     g_FolderNames (24)  := 'Lookup Dimension: Purchase Classification';
     g_FolderNames (25)  := 'Lookup Dimension: Receipt Exception';
     g_FolderNames (26)  := 'Lookup Dimension: Release Hold';
     g_FolderNames (27)  := 'Lookup Dimension: Shipment Approved';
     g_FolderNames (28)  := 'Lookup Dimension: Shipment Canceled';
     g_FolderNames (29)  := 'Lookup Dimension: Shipment Status';
     g_FolderNames (30)  := 'Lookup Dimension: Shipment Taxable';
     g_FolderNames (31)  := 'Lookup Dimension: Shipment Type';
     g_FolderNames (32)  := 'Lookup Dimension: Source Type';
     g_FolderNames (33)  := 'Lookup Dimension: Supply Agreement';
     g_FolderNames (34)  := 'Lookup Dimension: Transaction Reason';
     g_FolderNames (35)  := 'Lookup Dimension: User Entered';

     g_FolderNames (46)  := 'Person Dimension: Approver';
     g_FolderNames (47)  := 'Person Dimension: Deliver To Person';
     g_FolderNames (48)  := 'Person Dimension: Held By Employee';
     g_FolderNames (49)  := 'Person Dimension: Requestor';

     g_FolderNames (51)  := 'Time Dimension: Acceptance Date';
     g_FolderNames (52)  := 'Time Dimension: Acceptance Due Date';
     g_FolderNames (53)  := 'Time Dimension: Distribution Creation Date';
     g_FolderNames (54)  := 'Time Dimension: Due Date';
----------     g_FolderNames (55)  := 'Time Dimension: End Date';
     g_FolderNames (56)  := 'Time Dimension: Expected Arrival Date';
     g_FolderNames (57)  := 'Time Dimension: First Receipt Date';
     g_FolderNames (58)  := 'Time Dimension: Invoice Creation Date';
     g_FolderNames (59)  := 'Time Dimension: Invoice Received Date';
     g_FolderNames (60)  := 'Time Dimension: Last Accept Date';
     g_FolderNames (61)  := 'Time Dimension: Line Creation Date';
     g_FolderNames (62)  := 'Time Dimension: Parent Transaction Date';
     g_FolderNames (63)  := 'Time Dimension: Printed Date';
     g_FolderNames (64)  := 'Time Dimension: Purchase Creation Date';
     g_FolderNames (65)  := 'Time Dimension: Release Date';
     g_FolderNames (66)  := 'Time Dimension: Revised Date';
     g_FolderNames (67)  := 'Time Dimension: Shipment Approval Date';
     g_FolderNames (68)  := 'Time Dimension: Shipment Creation Date';
     g_FolderNames (69)  := 'Time Dimension: Shipped Date';
     g_FolderNames (70)  := 'Time Dimension: Source Shipment Creation Date';
---------     g_FolderNames (71)  := 'Time Dimension: Start Date';
     g_FolderNames (72)  := 'Time Dimension: Transaction Currency Date';

     g_FolderNames (80)  := 'Inventory Locator Dimension: Subinventory Locator';
     g_FolderNames (81)  := 'Unit of Measure Dimension: Transaction Unit of Measure';
--------- (used by ISC)       g_FolderNames (82)  := 'Set of Books Dimension: Set of Books';
     g_FolderNames (83)  := 'Supplier Item Dimension: Supplier Line Item Number';


     g_EulOwner := UPPER(pEulOwnerName);
     g_DiscoVersion := UPPER(pDiscoVersion);

       /* Set Bus Area */
     IF pDiscoVersion = 'DISCO3I' THEN
       InitBusArea3i (pBusAreaName);
     ELSIF pDiscoVersion = 'DISCO4I' THEN
       InitBusArea4i (pBusAreaName);
     ELSE
       RETURN;
     END IF;


    IF pDiscoVersion = 'DISCO3I' THEN
      l_index := g_FolderNames.FIRST;
      LOOP
        hideFolder3i (g_FolderNames (l_index));
        EXIT WHEN l_index = g_FolderNames.LAST;
        l_index := g_FolderNames.NEXT (l_index);
      END LOOP;
     ELSIF pDiscoVersion = 'DISCO4I' THEN
      l_index := g_FolderNames.FIRST;
      LOOP
        hideFolder4i (g_FolderNames (l_index));
        EXIT WHEN l_index = g_FolderNames.LAST;
        l_index := g_FolderNames.NEXT (l_index);
      END LOOP;
     END IF;

       /* Hide User Attributes */
     IF pDiscoVersion = 'DISCO3I' THEN
       hideUserAttributes3i;
     ELSIF pDiscoVersion = 'DISCO4I' THEN
       hideUserAttributes4i;
     END IF;

---------------------------------------------------------------

   EXCEPTION

   WHEN G_BUSINESS_AREA_DOES_NOT_EXIST THEN
      edw_log.put_line('Business Area Name: ' || g_EulBA_Name || ' not found');
      Errbuf  := g_errbuf;
      Retcode := g_retcode;
      raise;

   WHEN G_EUL_OWNER_DOES_NOT_EXIST THEN
      edw_log.put_line('End User Layer (EUL) Owner: ' || g_EulOwner || '  not found OR wrong EUL version: ' || pDiscoVersion);
      Errbuf  := g_errbuf;
      Retcode := g_retcode;
      raise;

   WHEN OTHERS THEN
      edw_log.put_line('pEulOwnerName: '|| g_EulOwner);
      edw_log.put_line('pBusAreaName: '|| pBusAreaName);
      edw_log.put_line('l_stmt : ' || l_stmt);
      Errbuf  := g_errbuf;
      Retcode := g_retcode;
      raise;

   END EulMain;

END POA_EUL_UTILS;

/
