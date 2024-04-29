--------------------------------------------------------
--  DDL for Package Body MTL_DEFAULT_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_DEFAULT_CATEGORY_SETS_PKG" AS
/* $Header: INVDCSTB.pls 120.1.12010000.2 2009/07/14 08:49:07 adasa ship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'EGO_DEF_FUNCTIONA_AREA_PKG';


 FUNCTION val_inventory_cat_set(P_Category_Set_Id NUMBER)   RETURN NUMBER;
 FUNCTION val_purchasing_cat_set(P_Category_Set_Id NUMBER)  RETURN NUMBER;
 FUNCTION val_planning_cat_set(P_Category_Set_Id NUMBER)    RETURN NUMBER;
 FUNCTION val_costing_cat_set(P_Category_Set_Id NUMBER)     RETURN NUMBER;
 FUNCTION val_eng_cat_set(P_Category_Set_Id NUMBER)         RETURN NUMBER;
 FUNCTION val_order_entry_cat_set(P_Category_Set_Id NUMBER) RETURN NUMBER;
-- FUNCTION val_Product_Line_cat_set(P_Category_Set_Id NUMBER)RETURN NUMBER;
 FUNCTION val_Product_reporting_Cat_Set(P_Category_Set_Id NUMBER) RETURN NUMBER;
 FUNCTION val_Asset_Management_Cat_Set(P_Category_Set_Id NUMBER)  RETURN NUMBER;
 FUNCTION val_Service_Cat_Set(P_Category_Set_Id NUMBER)     RETURN  NUMBER;
 FUNCTION val_Contracts_Cat_Set(P_Category_Set_Id NUMBER)   RETURN  NUMBER;
 FUNCTION val_UCCNet_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER; -- added for bug : 3953009
 FUNCTION val_UCCNet_GPC_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER;
-- FUNCTION Check_Mult_Assign_Flag RETURN  VARCHAR2;

--**********************************************************************
-- Functional Validations before updating MTL_DEFAULT_CATEGORY_SETS
--**********************************************************************

   PROCEDURE validate_all_cat_sets(P_Functional_area_id NUMBER,
                                   P_Category_Set_Id NUMBER,
                                   X_Msg_Name OUT NOCOPY VARCHAR2)
   IS
      rc      Number;
   BEGIN

      IF ( P_functional_area_id = 1 ) Then
         rc := val_inventory_cat_set(P_Category_Set_Id);
      elsif ( P_functional_area_id = 2 ) Then
         rc := val_purchasing_cat_set(P_Category_Set_Id);
      elsif ( P_functional_area_id = 3 ) Then
         rc := val_planning_cat_set(P_Category_Set_Id);
      elsif ( P_functional_area_id = 5 ) Then
         rc := val_costing_cat_set(P_Category_Set_Id);
      elsif ( P_functional_area_id = 6 ) Then
         rc := val_eng_cat_set(P_Category_Set_Id);
      elsif ( P_functional_area_id = 7 ) Then
         rc := val_order_entry_cat_set(P_Category_Set_Id);
   --   elsif ( :deflt_cat_set.functional_area_id = 8 ) Then
   --      rc := val_Product_Line_cat_set(P_Category_Set_Id);
      ELSIF ( P_functional_area_id = 9 ) THEN
         rc := val_Asset_Management_Cat_Set(P_Category_Set_Id);
      ELSIF ( P_functional_area_id = 4 ) THEN
         rc := val_Service_Cat_Set(P_Category_Set_Id);
      ELSIF ( P_functional_area_id = 10 ) THEN
         rc := val_Contracts_Cat_Set(P_Category_Set_Id);
      ELSIF ( P_functional_area_id = 11 ) THEN
         rc := val_Product_reporting_Cat_Set(P_Category_Set_Id);
      ELSIF (P_functional_area_id = 12 ) THEN
         rc :=val_UCCNet_Cat_Set(P_Category_Set_Id);--Bug:4082162
      ELSIF (P_functional_area_id = 21 ) THEN
         rc :=val_UCCNet_GPC_Cat_Set(P_Category_Set_Id);
      END IF;

      IF (rc = -2) THEN
           if ( P_functional_area_id = 2) THEN
             X_msg_Name := 'INV_CAT_PO_REFER';
           elsif ( P_functional_area_id = 5) THEN
             X_msg_Name := 'INV_CAT_CST_REFER';
           end if;
      END IF;

     IF ( rc = -1 ) THEN
   /*
       if ( P_functional_area_id = 8 ) THEN
         FND_MESSAGE.SET_NAME('INV', 'INV_PL_DEF_CAT_SET_WARN');
         if ( NOT FND_MESSAGE.Warn ) then
            :deflt_cat_set.category_set_id := :parameter.PL_DEF_CAT_SET_ID;

            select CATEGORY_SET_NAME, DESCRIPTION
            into   :deflt_cat_set.category_set_name, :deflt_cat_set.category_set_description
            from  MTL_CATEGORY_SETS_VL
            where CATEGORY_SET_ID = :deflt_cat_set.category_set_id;

            set_record_property(:system.cursor_record, 'DEFLT_CAT_SET', STATUS, QUERY_STATUS);
         end if;
       else */
            if ( P_functional_area_id = 11 ) THEN
              X_msg_Name :=  'INV_PR_DEF_CAT_SET_WARN';
            else
              X_msg_Name :=  'INV_ASSIGN_ITEM_TO_CS';
            end if;
   --    end if;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       X_msg_Name :=  'INV_UNHANDLED_EXCEPTION';

   END validate_all_cat_sets;


/* Function validating category set name for Inventory Function */

   FUNCTION val_inventory_cat_set(P_Category_Set_Id NUMBER) RETURN NUMBER
   IS
      buffer      VARCHAR2(1);
   Begin

     Select 'X'
     Into buffer
     FROM dual
     WHERE EXISTS (
     SELECT 'X'
     From MTL_SYSTEM_ITEMS_B Item
     Where  Item.INVENTORY_ITEM_FLAG = 'Y'
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       )
     );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         return 0;

   END val_inventory_cat_set;

   /* Function validating category set name for Purchasing Function */

   FUNCTION val_purchasing_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer      VARCHAR2(1);
      Old_Cat_value        NUMBER;
      Old_Structure_id     NUMBER;
      New_Structure_id     NUMBER;
      Po_Count             NUMBER  := 0;
      Sql_Stmt             Number  := 0;
   Begin

     Sql_Stmt := 1;
     Select STRUCTURE_ID
     Into   Old_Structure_id
     From   MTL_CATEGORY_SETS_B
     WHERE  CATEGORY_SET_ID = (select category_set_id
                               From   MTL_DEFAULT_CATEGORY_SETS
                               Where  FUNCTIONAL_AREA_ID = 2);

     Sql_Stmt := 3;
     Select STRUCTURE_ID
     Into   New_Structure_id
     From   MTL_CATEGORY_SETS_B
     WHERE  CATEGORY_SET_ID = P_Category_Set_Id;

     If New_Structure_id <> Old_Structure_Id Then
           Select count(*)
           Into   Po_Count
           From   Po_Line_Types_b
           where  category_id is NOT NULL
           and rownum < 2;

           If (Po_Count = 0) then
             Select count(*)
             Into   Po_Count
             From   PO_REQEXPRESS_LINES_ALL
             where  category_id is NOT NULL
             and rownum < 2;

             If (Po_Count = 0) then
               Select count(*)
               Into   Po_Count
               From   PO_AGENTS
               where  category_id is NOT NULL
               and rownum < 2;

               If (Po_Count = 0) then
                 Select count(*)
                 Into   Po_Count
                 From   PO_APPROVED_SUPPLIER_LIST
                 where  category_id is NOT NULL
                 and rownum < 2;

                 If (Po_Count = 0) then
                   Select count(*)
                   Into   Po_Count
                   From   PO_ASL_ATTRIBUTES
                   where  category_id is NOT NULL
                   and rownum < 2;

                   If (Po_Count = 0) then
                     Select count(*)
                     Into   Po_Count
                     From   PO_REQUISITION_LINES_ALL
                     where  category_id is NOT NULL
                     and rownum < 2;

                     If (Po_Count = 0) then
                       Select count(*)
                       Into   Po_Count
                       From   PO_LINES_ALL
                       where  category_id is NOT NULL
                       and rownum < 2;

                       If (Po_Count = 0) then
                         Select count(*)
                         Into   Po_Count
                         From   RCV_SHIPMENT_LINES
                         where  category_id is NOT NULL
                         and rownum < 2;
                       END IF;
                     END IF;
                   END IF;
                 END IF;
               END IF;
             END IF;
           END IF;
     END IF;

     If Po_count <> 0 then
       return -2;
     End if;

     Sql_Stmt := 4;
     Select DISTINCT 'X'
     Into buffer
     From MTL_SYSTEM_ITEMS_B Item
     Where  ( Item.PURCHASING_ITEM_FLAG = 'Y' OR
              Item.INTERNAL_ORDER_FLAG = 'Y' )
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
        If (Sql_Stmt = 4) then
         return 0;
        Else
         return -1;
        End if;
      WHEN OTHERS THEN
         return -1;
   END val_purchasing_cat_set;


/*  Function validating category set name for Planning Function */

   FUNCTION val_planning_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer      VARCHAR2(1);
   Begin

     Select 'X'
     Into buffer
     FROM dual
     WHERE EXISTS (
     SELECT 'X'
     From MTL_SYSTEM_ITEMS_B Item
     Where  Item.MRP_PLANNING_CODE <> 6
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       )
     );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         return 0;

   END val_planning_cat_set;


/* Function validating category set name for Costing Function */
   FUNCTION val_costing_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer     VARCHAR2(1);
      Old_Cat_value      NUMBER;
      Old_Structure_id   NUMBER;
      New_Structure_id   NUMBER;
      co_Count           NUMBER  := 0;
      Sql_Stmt           NUMBER  := 0;

      l_dyn_sql          VARCHAR2(500);
      source_cursor      INTEGER;
      ignore             INTEGER;

   Begin

     Sql_Stmt := 1;
     Select STRUCTURE_ID
     Into   Old_Structure_id
     From   MTL_CATEGORY_SETS_B
     WHERE  CATEGORY_SET_ID = (select category_set_id
                                From   MTL_DEFAULT_CATEGORY_SETS
                                Where  FUNCTIONAL_AREA_ID = 5);

     Sql_Stmt := 3;
     Select STRUCTURE_ID
     Into   New_Structure_id
     From   MTL_CATEGORY_SETS_B
     WHERE  CATEGORY_SET_ID = P_Category_Set_Id;


     If New_Structure_id <> Old_Structure_Id Then
         /* Select count(*)
          Into   co_Count
          From   Po_Line_Types_b
          where  category_id is NOT NULL
          and rownum < 2;

          If (co_Count = 0) then *//* Commented out for bugfix:8679416 */
             Select count(*)
             Into   co_Count
             From   CST_AP_VARIANCE_BATCHES
             where  category_id is NOT NULL
             and rownum < 2;

             If (co_Count = 0) then
               Select count(*)
               Into   co_Count
               From   CST_COST_TYPE_HISTORY
               where  category_id is NOT NULL
               and rownum < 2;

               If (co_Count = 0) then
                 Select count(*)
                 Into   co_Count
                 From   CST_COST_UPDATES
                 where  category_id is NOT NULL
                 and rownum < 2;

                 If (co_Count = 0) then
                  Select count(*)
                  Into   co_Count
                  From   CST_ITEM_OVERHEAD_DEFAULTS
                  where  category_id is NOT NULL
                  and rownum < 2;

                  If (co_Count = 0) then
                    Select count(*)
                    Into   co_Count
                    From   CST_ITEM_OVERHEAD_DEFAULTS_EFC
                    where  category_id is NOT NULL
                    and rownum < 2;

                    If (co_Count = 0) then

                       IF INV_ITEM_UTIL.Object_Exists(p_object_type => 'SYNONYM'
                                                     ,p_object_name => 'CST_MATERIAL_OVHD_RULES') ='Y'
                       THEN
                          source_cursor := dbms_sql.open_cursor;
                          l_dyn_sql     := ' Select count(*)                      '||
                                           ' From   CST_MATERIAL_OVHD_RULES       '||
                                           ' where  category_id is NOT NULL       '||
                                           ' and rownum < 2';
                          DBMS_SQL.PARSE(source_cursor,l_dyn_sql,1);
                          DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, co_Count);
                          ignore := DBMS_SQL.EXECUTE(source_cursor);
                          IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
                             DBMS_SQL.COLUMN_VALUE(source_cursor, 1, co_Count);
                          END IF;
                          DBMS_SQL.CLOSE_CURSOR(source_cursor);
                       END IF;
                    If (co_Count = 0) then
                         Select count(*)
                         Into   co_Count
                         From   CST_SC_ROLLUP_HISTORY
                         where  category_id is NOT NULL
                         and rownum < 2;
                       END IF;
                     END IF;
                   END IF;
                 END IF;
               END IF;
             END IF;
          -- END IF;/* commented out for bugfix:8679416 */
     END IF;

     If co_Count <> 0 then
       return -2;
     End if;

     Sql_Stmt := 4;
     Select DISTINCT 'X'
     Into buffer
     From MTL_SYSTEM_ITEMS_B Item
     Where  Item.COSTING_ENABLED_FLAG = 'Y'
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
      );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
        If (Sql_Stmt = 4) then
         return 0;
        Else
         return -1;
        End if;
      WHEN OTHERS THEN
         return -1;

   END val_costing_cat_set;

/* Function validating category set name for Engineering Function */

   FUNCTION val_eng_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer VARCHAR2(1);
   Begin

     Select 'X'
     Into buffer
     FROM dual
     WHERE EXISTS (
     SELECT 'X'
     From MTL_SYSTEM_ITEMS_B Item
     Where  Item.ENG_ITEM_FLAG = 'Y'
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       )
     );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         return 0;

   END val_eng_cat_set;


/* Function validating category set name for Order Entry Function */

   FUNCTION val_order_entry_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer VARCHAR2(1);
   Begin

     Select 'X'
     Into buffer
     FROM dual
     WHERE EXISTS (
     SELECT 'X'
     From MTL_SYSTEM_ITEMS_B Item
     Where  Item.CUSTOMER_ORDER_FLAG = 'Y'
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       )
     );

     return -1;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         return 0;

   END val_order_entry_cat_set;

/* function validating category set name for Product_Line function

FUNCTION val_Product_Line_cat_set(P_Category_Set_Id NUMBER) RETURN  NUMBER
IS
BEGIN

   if ( :parameter.PL_DEF_CAT_SET_ID != P_Category_Set_Id ) then
      return -1;
   else
      return 0;
   end if;

   RETURN NULL;

END val_Product_Line_cat_set;*/


/* FUNCTION validating category set name for Asset Management function */

   FUNCTION val_Asset_Management_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      l_count      NUMBER;
   BEGIN

      SELECT  DECODE( COUNT(*), 0, 0, -1 )
        INTO  l_count
      FROM  MTL_SYSTEM_ITEMS_B  Item
      WHERE
         Item.EAM_ITEM_TYPE IS NOT NULL
         AND  NOT EXISTS
              ( SELECT 'X'
                FROM  MTL_ITEM_CATEGORIES  Cat
                WHERE
                        Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
                   AND  Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
                   AND  Cat.CATEGORY_SET_ID   = P_Category_Set_Id
              );

      RETURN (l_count);

   END val_Asset_Management_Cat_Set;

/* Function validating category set name for Service Function */

   FUNCTION val_Service_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      l_count      NUMBER;
   BEGIN

      SELECT  DECODE( COUNT(*), 0, 0, -1 )
        INTO  l_count
      FROM  MTL_SYSTEM_ITEMS_B  Item
      WHERE
         Item.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE', 'WARRANTY')
         AND  NOT EXISTS
              ( SELECT 'X'
                FROM  MTL_ITEM_CATEGORIES  Cat
                WHERE
                        Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
                   AND  Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
                   AND  Cat.CATEGORY_SET_ID   = P_Category_Set_Id
              );

      RETURN (l_count);

   END val_Service_Cat_Set;

/* Function validating category set name for Contracts Function */
   FUNCTION val_Contracts_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      l_count      NUMBER;
   BEGIN

      SELECT DECODE( COUNT(*), 0, 0, -1 )
        INTO l_count
      FROM  MTL_SYSTEM_ITEMS_B  Item
      WHERE
         Item.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE', 'WARRANTY', 'SUBSCRIPTION', 'USAGE')
         AND  NOT EXISTS
              ( SELECT 'X'
                FROM  MTL_ITEM_CATEGORIES  Cat
                WHERE
                        Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
                   AND  Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
                   AND  Cat.CATEGORY_SET_ID   = P_Category_Set_Id
              );

      RETURN (l_count);

   END val_Contracts_Cat_Set;

/* Private Function validating category set name for Product Reporting/DBI Function */

   FUNCTION val_Product_reporting_Cat_Set(P_Category_Set_Id NUMBER) RETURN  NUMBER
   IS
      buffer      VARCHAR2(1);
   Begin

     Select 'X'
     Into buffer
     FROM dual
     WHERE EXISTS (
     SELECT 'X'
     From MTL_SYSTEM_ITEMS_B Item
     Where  ( Item.CUSTOMER_ORDER_FLAG = 'Y' OR
              Item.INTERNAL_ORDER_FLAG = 'Y' )
     And    NOT EXISTS
       ( Select 'X'
         From  MTL_ITEM_CATEGORIES Cat
         Where Cat.INVENTORY_ITEM_ID = Item.INVENTORY_ITEM_ID
         And   Cat.ORGANIZATION_ID   = Item.ORGANIZATION_ID
         And   Cat.CATEGORY_SET_ID   = P_Category_Set_Id
       )
     );
     return -1;
   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         return 0;

   END val_Product_reporting_Cat_Set;


/* Private Function validating Category Set for UCCNet */
--Bug:4082162 User can change the default category set (catalog) to new default catalog
-- ONLY if all the items belongs to current category set are already assigned to
-- new category set(Catalog).
  FUNCTION val_UCCNet_Cat_Set(P_Category_Set_Id NUMBER)
  RETURN  NUMBER
  IS
      buffer      VARCHAR2(1);
  Begin

        Select 'X'
        Into buffer
        From    MTL_ITEM_CATEGORIES Cat,
                MTL_DEFAULT_CATEGORY_SETS DefCat
        Where DefCat.FUNCTIONAL_AREA_ID   = 12
          And DefCat.CATEGORY_SET_ID  = Cat.CATEGORY_SET_ID
          And NOT EXISTS
               ( Select 'X'
                   From  MTL_ITEM_CATEGORIES Cat1
                  Where   Cat1.INVENTORY_ITEM_ID = Cat.INVENTORY_ITEM_ID
                    And   Cat1.ORGANIZATION_ID   = Cat.ORGANIZATION_ID
                    And   Cat1.CATEGORY_SET_ID   = P_Category_Set_Id
                )
          And rownum=1;
        return -1;
        EXCEPTION

        WHEN NO_DATA_FOUND THEN
                return 0;
  End val_UCCNet_Cat_Set;

/* Private Function validating Category Set for UCCNet GPC Catalog */
--User can change the default category set (catalog) to new default catalog
-- ONLY if all the items belongs to current category set are already assigned to
-- new category set(Catalog).
  FUNCTION val_UCCNet_GPC_Cat_Set(P_Category_Set_Id NUMBER)
  RETURN  NUMBER
  IS
      buffer      VARCHAR2(1);
  Begin

        Select 'X'
        Into buffer
        From    MTL_ITEM_CATEGORIES Cat,
                MTL_DEFAULT_CATEGORY_SETS DefCat
        Where DefCat.FUNCTIONAL_AREA_ID   = 21
          And DefCat.CATEGORY_SET_ID  = Cat.CATEGORY_SET_ID
          And NOT EXISTS
               ( Select 'X'
                   From  MTL_ITEM_CATEGORIES Cat1
                  Where   Cat1.INVENTORY_ITEM_ID = Cat.INVENTORY_ITEM_ID
                    And   Cat1.ORGANIZATION_ID   = Cat.ORGANIZATION_ID
                    And   Cat1.CATEGORY_SET_ID   = P_Category_Set_Id
                )
          And rownum=1;
        return -1;
        EXCEPTION

        WHEN NO_DATA_FOUND THEN
                return 0;
  End val_UCCNet_GPC_Cat_Set;


END MTL_DEFAULT_CATEGORY_SETS_PKG;

/
