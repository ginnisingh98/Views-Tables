--------------------------------------------------------
--  DDL for Package Body JA_CN_CUSTOM_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CUSTOM_SOURCES" AS
  --$Header: JACNSCSB.pls 120.8.12010000.3 2009/06/01 09:14:42 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|      JACNSCSB.pls                                                     |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to create customer source.           |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|                                                                       |
  --|      PROCEDURE    Invoice_Category     PUBLIC                         |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      01/08/2007     yanbo liu         Created                         |
  --|      05/18/2009     Chaoqun Wu        Fixing bug# 8402674             |
  --|      01/06/2009     Chaoqun Wu       Fixing bug#8478003
  --|                                                                       |
  --+======================================================================*/

  --==========================================================================
  --  FUNCTION NAME:
  --  Refund_Item      Private
  --
  --  DESCRIPTION:
  --    This procedure is used to return source value when the invoice is
  --    'Refund' association.
  --
  --  PARAMETERS:
  --      p_invoice_id                   invoice id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     05/18/2009     Chaoqun Wu        Added for fixing bug# 8402674
  --===========================================================================
 FUNCTION Refund_Item(p_invoice_id                 IN  NUMBER)
   RETURN VARCHAR2 IS
    l_refund_item             VARCHAR2(10) := '';
    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Refund_Item';

    BEGIN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'p_invoice_id  '||p_invoice_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    SELECT 'Refund'
      INTO l_refund_item
      FROM AP_INVOICES_ALL aia
     WHERE aia.INVOICE_ID = P_INVOICE_ID
       and aia.PAY_PROC_TRXN_TYPE_CODE='AR_CUSTOMER_REFUND'
       and aia.INVOICE_TYPE_LOOKUP_CODE = 'PAYMENT REQUEST';

    RETURN l_refund_item;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;
    END Refund_Item;

    --==========================================================================
  --  FUNCTION NAME:
  --  GDF_Item      Private
  --
  --  DESCRIPTION:
  --    This procedure is used to return source value when the invoice source is
  --    'Manual Invoice Entry'. The return value is GDF in Invoice distribution
  --    or header.The priority of distribution is over than header.
  --
  --  PARAMETERS:
  --      p_invoice_id                   invoice id
  --      p_invoice_distribution_id      invoice distribution id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     06/08/2007     yanbo liu        updated
  --===========================================================================
 FUNCTION GDF_Item(p_invoice_id                 IN  NUMBER,
                     p_invoice_distribution_id    IN  NUMBER)
   RETURN VARCHAR2 IS
    GDF_Item  ap_invoice_distributions_all.global_attribute1%type:=null;
    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='GDF_Item';

    BEGIN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'p_invoice_id  '||p_invoice_id
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'p_invoice_distribution_id'||p_invoice_distribution_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    --First get custom source value from distribution

        SELECT GLOBAL_ATTRIBUTE1
        INTO GDF_ITEM
        FROM AP_INVOICE_DISTRIBUTIONS_ALL
        WHERE INVOICE_DISTRIBUTION_ID=P_INVOICE_DISTRIBUTION_ID;

        --IF THE VALUE IN DISTRIBUTION IS NULL,
        --THEN GET THE VALUE FROM HEADER.
        IF GDF_ITEM IS NULL THEN
          SELECT GLOBAL_ATTRIBUTE1
          INTO GDF_ITEM
          FROM AP_INVOICES_ALL
          WHERE INVOICE_ID=P_INVOICE_ID;
        END IF;

        RETURN GDF_ITEM;

      --  RETURN nvl(GDF_ITEM,'gdf_item_0') ;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;
     --   return('gdf_item0');
    END GDF_Item;
  --==========================================================================
  --  FUNCTION NAME:
  --  Master_Item                  Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return source value when the invoice source is
  --    'ERS'.The return value is Category Set In Master Item
  --
  --  PARAMETERS:
  --      p_invoice_distribution_id      invoice distribution id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     06/08/2007     yanbo liu        updated
  --     09/08/2007     yanbo liu        updated
  --     07/12/2007     xiao lv          updated
  --     get item logic change
  --===========================================================================
  FUNCTION MASTER_ITEM_UPDATE(P_INVOICE_ID                  IN NUMBER,
                       P_INVOICE_DISTRIBUTION_ID     IN  NUMBER)
    RETURN VARCHAR2 IS
    MASTER_ITEM              VARCHAR(100):=null;
    L_INVOICE_LINE_NUMBER     NUMBER;
    L_INVOICE_ID              NUMBER;
    --new variable
    L_PO_HEADER_ID            NUMBER;
    L_PO_LINE_ID              NUMBER;
    --
    L_DBG_LEVEL               NUMBER        :=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    L_PROC_LEVEL              NUMBER        :=FND_LOG.LEVEL_PROCEDURE;
    L_PROC_NAME               VARCHAR2(100) :='MASTER_ITEM';
    a EXCEPTION;


    BEGIN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'p_invoice_distribution_id '||p_invoice_distribution_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

        -- get the invoice line number and invoice id from ap_invoice_distributions_all
        SELECT INVOICE_LINE_NUMBER,INVOICE_ID
        INTO L_INVOICE_LINE_NUMBER,L_INVOICE_ID
        FROM AP_INVOICE_DISTRIBUTIONS_ALL
        WHERE INVOICE_DISTRIBUTION_ID=P_INVOICE_DISTRIBUTION_ID ;

       --get key flexfield concatenated_segments as source value
       --CATEGORY SET NAME is 'Cash Flow Category'
   BEGIN
    SELECT MC.CONCATENATED_SEGMENTS
       INTO MASTER_ITEM
       FROM MTL_CATEGORIES_B_KFV MC
       WHERE CATEGORY_ID IN(
           SELECT CATEGORY_ID
           FROM MTL_ITEM_CATEGORIES MIC
           WHERE MIC.CATEGORY_SET_ID IN (
                  SELECT CATEGORY_SET_ID
                  FROM MTL_CATEGORY_SETS_TL MCST
                  WHERE MCST.LANGUAGE = USERENV('LANG')
                  AND MCST.CATEGORY_SET_NAME = 'Cash Flow Category')
           AND INVENTORY_ITEM_ID IN(
                  SELECT ITEM_ID
                  FROM PO_LINES_ALL
                  WHERE PO_HEADER_ID = (
                          SELECT PO_HEADER_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
                  AND   PO_LINE_ID = (
                          SELECT PO_LINE_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
                  )
            AND ORGANIZATION_ID IN(
                          SELECT ORG_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
           );

       EXCEPTION
         WHEN OTHERS THEN
        --updated by lyb, for custom source for tax 6666473
             IF MASTER_ITEM IS NULL
             THEN
               SELECT PO_HEADER_ID,
                      PO_LINE_ID
                 INTO L_PO_HEADER_ID,
                      L_PO_LINE_ID
                 FROM ap_invoice_lines_all al
                WHERE RCV_TRANSACTION_ID = (
                         SELECT RCV_TRANSACTION_ID
                           FROM ap_invoice_lines_all ap
                          WHERE ap.invoice_id = P_INVOICE_ID
                            AND ap.LINE_NUMBER = L_INVOICE_LINE_NUMBER)

                  AND INVOICE_ID = P_INVOICE_ID
                  AND PO_HEADER_ID IS NOT NULL
                  AND PO_LINE_ID IS NOT NULL;

             --get key flexfield concatenated_segments as source value
             --CATEGORY SET NAME is 'Cash Flow Category'
                SELECT MC.CONCATENATED_SEGMENTS
                  INTO MASTER_ITEM
                  FROM MTL_CATEGORIES_B_KFV MC
                 WHERE CATEGORY_ID IN(
                    SELECT CATEGORY_ID
                      FROM MTL_ITEM_CATEGORIES MIC
                     WHERE MIC.CATEGORY_SET_ID IN (
                           SELECT CATEGORY_SET_ID
                             FROM MTL_CATEGORY_SETS_TL MCST
                            WHERE MCST.LANGUAGE = USERENV('LANG')
                              AND MCST.CATEGORY_SET_NAME = 'Cash Flow Category')
                       AND INVENTORY_ITEM_ID IN(
                              SELECT ITEM_ID
                              FROM PO_LINES_ALL
                              WHERE PO_HEADER_ID = L_PO_HEADER_ID
                              AND   PO_LINE_ID = L_PO_LINE_ID
                              )
                       AND ORGANIZATION_ID IN(
                                      SELECT ORG_ID
                                      FROM AP_INVOICE_LINES_ALL AP
                                      WHERE AP.INVOICE_ID=L_INVOICE_ID
                                      AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
                       );


               END IF;

               IF MASTER_ITEM IS NOT NULL THEN
                   RETURN MASTER_ITEM;
               END IF;

           RAISE A;
         END;
       --==========================================================================

       --==========================================================================

         RETURN MASTER_ITEM;
       --RETURN nvl(MASTER_ITEM,'master_item_0');

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        IF MASTER_ITEM IS NULL THEN
          MASTER_ITEM := GDF_Item(p_invoice_id,
                                   p_invoice_distribution_id
                                 );
          RETURN MASTER_ITEM;
        END IF;
            RAISE;
             --  return('master_item_exp');
    END MASTER_ITEM_UPDATE;



    --==========================================================================
  --  FUNCTION NAME:
  --  Expense_Item                  Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return source value when the invoice source is
  --    'Oracle Internet Expenses' or 'Payables Expense Reports'.
  --    The return value is Expenses Item.
  --
  --
  --  PARAMETERS:
  --      invoice_distribution_id        invoice distribution id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     06/08/2007     yanbo liu        updated
  --===========================================================================
   FUNCTION Expense_Item(P_INVOICE_ID                IN NUMBER,
                         p_invoice_distribution_id   IN  NUMBER)
    RETURN VARCHAR2 IS
    Expense_Item_desc  ap_invoice_distributions_all.description%type:=null;
    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Expense_Item';

    BEGIN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'invoice_distribution_id'||p_invoice_distribution_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    --get the custom value from destribution
        SELECT description
        INTO Expense_Item_desc
        FROM ap_invoice_distributions_all
        WHERE invoice_distribution_id=p_invoice_distribution_id ;
        RETURN Expense_Item_desc;
        --RETURN nvl(Expense_Item_desc,'expense_item_desc_0');
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
       IF Expense_Item_desc IS NULL THEN
          Expense_Item_desc := GDF_Item(p_invoice_id,
                                   p_invoice_distribution_id
                                 );
          RETURN Expense_Item_desc;
        END IF;
       RAISE;
       -- return('expense_item0');
    END Expense_Item;
 --==========================================================================
  --  FUNCTION NAME:
  --  Master_Item                  Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return source value when the invoice source is
  --    'ERS'.The return value is Category Set In Master Item
  --
  --  PARAMETERS:
  --      p_invoice_distribution_id      invoice distribution id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     06/08/2007     yanbo liu        updated
  --     09/08/2007     yanbo liu        updated
  --     get item logic change
  --===========================================================================
  FUNCTION MASTER_ITEM(P_INVOICE_ID                  IN NUMBER,
                       P_INVOICE_DISTRIBUTION_ID     IN  NUMBER)
    RETURN VARCHAR2 IS
    MASTER_ITEM              VARCHAR(100):=null;
    L_INVOICE_LINE_NUMBER     NUMBER;
    L_INVOICE_ID              NUMBER;
    L_DBG_LEVEL               NUMBER        :=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    L_PROC_LEVEL              NUMBER        :=FND_LOG.LEVEL_PROCEDURE;
    L_PROC_NAME               VARCHAR2(100) :='MASTER_ITEM';
    a EXCEPTION;


    BEGIN
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'p_invoice_distribution_id '||p_invoice_distribution_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

        -- get the invoice line number and invoice id from ap_invoice_distributions_all
        SELECT INVOICE_LINE_NUMBER,INVOICE_ID
        INTO L_INVOICE_LINE_NUMBER,L_INVOICE_ID
        FROM AP_INVOICE_DISTRIBUTIONS_ALL
        WHERE INVOICE_DISTRIBUTION_ID=P_INVOICE_DISTRIBUTION_ID ;

       --get key flexfield concatenated_segments as source value
       --CATEGORY SET NAME is 'Cash Flow Category'
    SELECT MC.CONCATENATED_SEGMENTS
       INTO MASTER_ITEM
       FROM MTL_CATEGORIES_B_KFV MC
       WHERE CATEGORY_ID IN(
           SELECT CATEGORY_ID
           FROM MTL_ITEM_CATEGORIES MIC
           WHERE MIC.CATEGORY_SET_ID IN (
                  SELECT CATEGORY_SET_ID
                  FROM MTL_CATEGORY_SETS_TL MCST
                  WHERE MCST.LANGUAGE = USERENV('LANG')
                  AND MCST.CATEGORY_SET_NAME = 'Cash Flow Category')
           AND INVENTORY_ITEM_ID IN(
                  SELECT ITEM_ID
                  FROM PO_LINES_ALL
                  WHERE PO_HEADER_ID = (
                          SELECT PO_HEADER_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
                  AND   PO_LINE_ID = (
                          SELECT PO_LINE_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
                  )
            AND ORGANIZATION_ID IN(
                          SELECT ORG_ID
                          FROM AP_INVOICE_LINES_ALL AP
                          WHERE AP.INVOICE_ID=L_INVOICE_ID
                          AND AP.LINE_NUMBER=L_INVOICE_LINE_NUMBER)
           );

         RETURN MASTER_ITEM;
       --RETURN nvl(MASTER_ITEM,'master_item_0');

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        IF MASTER_ITEM IS NULL THEN
          MASTER_ITEM := GDF_Item(p_invoice_id,
                                   p_invoice_distribution_id
                                 );
          RETURN MASTER_ITEM;
        END IF;
            RAISE;
             --  return('master_item_exp');
    END Master_Item;

  --==========================================================================
  --  FUNCTION NAME:
  --    Invoice_Category                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return different source value according to
  --    invoice source input.
  --
  --  PARAMETERS:
  --      p_Invoice_Source               invoice source
  --      p_invoice_id                   invoice id
  --      p_invoice_line_number          invoice line number
  --      p_distribution_line_number     distribution line number
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --     06/08/2007     yanbo liu        updated
  --===========================================================================
  FUNCTION Invoice_Category(p_Invoice_Source            IN VARCHAR2,
                            p_invoice_id                IN  NUMBER,
                            p_invoice_distribution_id  IN  NUMBER)
    RETURN VARCHAR2 IS
    Source_Value  VARCHAR2(200):=NULL;
    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='Invoice Category';
  BEGIN

  IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'p_Invoice_Source '||p_Invoice_Source
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'p_invoice_id  '||p_invoice_id
                    );

      FND_LOG.String(l_proc_level
                    ,l_module_prefix||'.'||l_proc_name||'.parameters'
                    ,'p_invoice_distribution_id'||p_invoice_distribution_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    --  This function will call different function and return different value
    --  according to the parameter Invoice Source.

    IF p_Invoice_Source IS NULL OR p_invoice_id IS NULL OR p_invoice_distribution_id IS NULL THEN
        RETURN NULL;
    ELSE
        CASE p_Invoice_Source
          WHEN 'Manual Invoice Entry'
          THEN
              Source_Value := GDF_Item(p_invoice_id,
                                       p_invoice_distribution_id
                                       );
          WHEN 'SelfService'
          THEN
              Source_Value := Expense_Item(p_invoice_id,
                                           p_invoice_distribution_id);
          WHEN 'XpenseXpress'
          THEN
              Source_Value := Expense_Item(p_invoice_id,
                                           p_invoice_distribution_id);
          WHEN 'ERS'
          THEN
              Source_Value := MASTER_ITEM_UPDATE(p_invoice_id,
                                          p_invoice_distribution_id);
          --Begin: Added for fixing bug# 8402674
          WHEN 'Receivables'
          THEN
              Source_Value := Refund_ITEM(p_invoice_id);
          --End: Added for fixing bug# 8402674
          ELSE
              Source_Value := GDF_Item(p_invoice_id,
                                       p_invoice_distribution_id
                                     );
        END CASE ;

        IF (l_proc_level >= l_dbg_level)
          THEN
            FND_LOG.STRING(l_proc_level,
                           l_module_prefix|| '.' || l_proc_name || '.end',
                           'end procedure');
          END IF;
         RETURN Source_Value;
        -- RETURN nvl(Source_Value,'0');
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)

        RETURN NULL;
        RAISE;
     --  return('invoice_category');
  END Invoice_Category;
    --==========================================================================
  --  FUNCTION NAME:
  --  GET_PROJECT_NUM                 Public
  --
  --  DESCRIPTION:
  --    This procedure is used to return project number according to project id
  --
  --
  --  PARAMETERS:
  --      Project_id         Project id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --  09/08/2007     yanbo liu        updated
  --  01/06/2009     Chaoqun Wu       Fixing bug#8478003
  --===========================================================================

  FUNCTION GET_PROJECT_NUM(p_project_id           IN  NUMBER) --Fixing bug#8478003
  RETURN VARCHAR2 IS
    l_project_num             PA_PROJECTS_ALL.Segment1%type:=null;
    l_dbg_level               NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level              NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name               VARCHAR2(100) :='GET_PROJECT_NUM';
  BEGIN

    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'Project_id  '||p_project_id
                    );

    END IF;  --(l_proc_level >= l_dbg_level)

    --get project number by project id.
    IF p_project_id IS NULL THEN
       RETURN NULL;
    ELSE
     SELECT ppa.SEGMENT1
       INTO l_project_num
       FROM PA_PROJECTS_ALL ppa
      WHERE ppa.PROJECT_ID = p_project_id;
     RETURN l_project_num;
    END IF;

    EXCEPTION

      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        RETURN NULL;
        RAISE;
  END GET_PROJECT_NUM;


BEGIN
  NULL;
  -- Initialization
--  <Statement>;
end JA_CN_CUSTOM_SOURCES;




/
