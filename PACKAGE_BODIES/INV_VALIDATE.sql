--------------------------------------------------------
--  DDL for Package Body INV_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_VALIDATE" AS
/* $Header: INVSVATB.pls 120.14.12010000.5 2010/10/12 23:41:52 vissubra ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Validate';
g_orgid NUMBER;

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Desc_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'date_required';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header_status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'status_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_delivered';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_detailed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'serial_number_end';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'serial_number_start';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'uom';
--INVCONV
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'secondary_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'secondary_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'secondary_quantity_delivered';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'secondary_quantity_detailed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'grade_code';
--INVCONV

--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN NUMBER
IS
BEGIN

    --  Call FND validate API.


    --  This call is temporarily commented out

    RETURN T;

END Desc_Flex;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
function check_creation_updation(p_created_updated_by in number,
             p_is_creation in number)
  RETURN NUMBER
  is
     l_dummy varchar2(10);

begin

       IF p_created_updated_by IS NULL OR
    p_created_updated_by = FND_API.G_MISS_NUM
    then
     return p_is_creation;
       END IF;

       SELECT  'VALID'
    INTO    l_dummy
    FROM    FND_USER
    WHERE   USER_ID = p_created_updated_by;

       RETURN T;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

    FND_MESSAGE.SET_NAME('INV','INV_INT_USERCODE');
    FND_MSG_PUB.Add;

      END IF;

      RETURN F;


   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    if (p_is_creation = T)
      then
       FND_MSG_PUB.Add_Exc_Msg
         (   G_PKG_NAME
        ,   'Created_By'
        );
     else
       FND_MSG_PUB.Add_Exc_Msg
         (   G_PKG_NAME
        ,   'Last_Updated_By'
        );
    END IF;
      end if;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end check_creation_updation;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Created_By ( p_created_by IN NUMBER )
RETURN NUMBER
  is

BEGIN

      return check_creation_updation(p_created_by,T);

END Created_By;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
function check_date (p_date in date, p_msg in varchar2)
RETURN NUMBER
  is
begin
   IF p_date IS NULL OR
     p_date = FND_API.G_MISS_DATE
     THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
    FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV',p_msg),FALSE);
    FND_MSG_PUB.Add;
      END IF;
      RETURN F;
   END IF;
   return T;
end check_date;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Creation_Date ( p_creation_date IN date)
  RETURN NUMBER
  IS
BEGIN

     return check_date(p_creation_date, 'DATE');

END Creation_Date;


-- ---------------------------------------------------------------------
-- Bug 4373226 added parameter transaction_date for
-- checking the conversion rate on the basis of
-- transaction date but not on sysdate
-- ---------------------------------------------------------------------
FUNCTION conversion_rate(from_org IN NUMBER,
          to_org IN NUMBER,transaction_date DATE  DEFAULT SYSDATE)
  RETURN NUMBER
  IS
     l_sob_id NUMBER;
     l_xfr_sob_id NUMBER;
     l_currency_code VARCHAR(15);
     l_xfr_currency_code VARCHAR(15);
     l_conv_type VARCHAR(240);
     l_rate NUMBER;
     excep varchar2(100);

BEGIN

   SELECT set_of_books_id
     INTO l_sob_id
     FROM org_organization_definitions
     WHERE organization_id = from_org;

   SELECT set_of_books_id
     INTO l_xfr_sob_id
     FROM org_organization_definitions
     WHERE organization_id = to_org;

   SELECT currency_code
     INTO l_currency_code
     FROM gl_sets_of_books
     WHERE set_of_books_id = l_sob_id;

   SELECT currency_code
     INTO l_xfr_currency_code
     FROM gl_sets_of_books
     WHERE set_of_books_id = l_xfr_sob_id;


   IF (l_currency_code <> l_xfr_currency_code)
     THEN
      fnd_profile.get('CURRENCY_CONVERSION_TYPE',l_conv_type);

      l_rate := gl_currency_api.get_closest_rate(l_sob_id,
                   l_xfr_currency_code,
                   transaction_date,
                   l_conv_type,
                   NULL);

--      RETURN T;
   END IF;

   RETURN T;
   --   END IF;

EXCEPTION

   WHEN gl_currency_api.NO_RATE THEN
      RETURN F;

   WHEN OTHERS THEN
      RETURN f;

END conversion_rate;




-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Description ( p_description IN VARCHAR2 )
RETURN NUMBER
IS
BEGIN
     return T;
END Description;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Employee(p_employee_id IN OUT NOCOPY NUMBER,
        p_last_name IN OUT NOCOPY VARCHAR2,
        p_full_name IN OUT NOCOPY VARCHAR2,
        p_org IN ORG)
  RETURN NUMBER
  IS
BEGIN

   IF  p_employee_id IS NULL AND
       p_last_name IS NULL AND
       p_full_name IS NULL THEN
      RETURN F;
   END IF;

   IF p_employee_id IS NOT NULL THEN
      SELECT last_name,full_name
   INTO p_last_name,p_full_name
   FROM mtl_employees_current_view
   WHERE employee_id = p_employee_id
   AND organization_id = p_org.organization_id;
    ELSE
      BEGIN
        SELECT employee_id,last_name,full_name
      INTO p_employee_id,p_last_name,p_full_name
      FROM mtl_employees_current_view
      WHERE organization_id = p_org.organization_id
      -- Bug 4951746, following where clause voided the index use
      -- therefore cauased performance issue
      -- changed to avoid the NVL and DECODE
      --       AND (NVL(last_name,'@@@@') = DECODE(last_name,NULL,'@@@@',p_last_name)
      --        OR NVL(full_name,'@@@@') = DECODE(full_name,NULL,'@@@@',p_full_name));
      AND

-- Bug 6061411
( -- Added this brace to make this work as expected
(p_last_name is null OR
           (p_last_name is not null and last_name = p_last_name))
      OR  (p_full_name is null OR
           (p_full_name is not null and full_name = p_full_name)
) -- Added this brace to make it work as expected
);

-- End of Bug 6061411

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE NO_DATA_FOUND;
        WHEN TOO_MANY_ROWS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('INV','HR_51340_EMP_EMP_NUM_REQ');
            FND_MSG_PUB.Add;
          END IF;
          RETURN F;
      END;
   END IF;

   RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','HR_7676_BOOKING_FLAG_CHANGE');
            FND_MSG_PUB.Add;
        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Employee'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END employee;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION From_Subinventory ( p_sub IN OUT nocopy sub,
                             p_org IN ORG,
                             p_item IN ITEM,
                             p_acct_txn IN NUMBER)
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
v_expense_to_asset_profile    VARCHAR2(1);
BEGIN

    IF p_sub.secondary_inventory_name IS NULL OR
        p_sub.secondary_inventory_name = FND_API.G_MISS_CHAR
    THEN
        RETURN F;
    END IF;

    FND_PROFILE.GET('INV:EXPENSE_TO_ASSET_TRANSFER',v_expense_to_asset_profile);
    if( NVL(v_expense_to_asset_profile,'2') = '1')
    then
       if(p_acct_txn = 1)
       then
         if p_item.restrict_subinventories_code = 1
         then
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_ITEM_SUB_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND INVENTORY_ITEM_ID = p_item.inventory_item_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         else
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_SUBINVENTORIES_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         end if;
       else
         if p_item.restrict_subinventories_code = 1
         then
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_ITEM_SUB_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND INVENTORY_ITEM_ID = p_item.inventory_item_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         else
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_SUBINVENTORIES_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         end if;
       end if;
    else
       if(p_acct_txn = 1)
       then
         if p_item.restrict_subinventories_code = 1
         then
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_ITEM_SUB_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND INVENTORY_ITEM_ID = p_item.inventory_item_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         else
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_SUBINVENTORIES_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         end if;
       else
         if p_item.restrict_subinventories_code = 1
         then
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_ITEM_SUB_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND INVENTORY_ITEM_ID = p_item.inventory_item_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         else
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_SUBINVENTORIES_TRK_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         end if;
       end if;
    end if;
    SELECT *
      INTO p_sub
      FROM MTL_SECONDARY_INVENTORIES
      WHERE ORGANIZATION_ID = p_org.organization_id
        AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;

    RETURN T;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_INT_SUBCODE');
            FND_MSG_PUB.Add;
        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'From_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END From_Subinventory;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
/*
 * Bug# 6633612
 * Overloaded From_Subinventory function for Material Status Enhancement Project
 */
FUNCTION From_Subinventory ( p_sub IN OUT nocopy sub,
                             p_org IN ORG,
                             p_item IN ITEM,
                             p_acct_txn IN NUMBER,
                             p_trx_type_id IN NUMBER, -- For Bug# 6633612
                             p_object_type IN VARCHAR2 DEFAULT 'Z' -- For Bug# 6633612
                           )
RETURN NUMBER
IS
l_result                   NUMBER;
l_status_result            VARCHAR2(1);
BEGIN

  /* First call the original From_Subinventory function,
   * If it returns INV_VALIDATE.T then goahead to call
   * inv_material_status_grp.is_status_applicable() function.
   */
  l_result := INV_VALIDATE.From_Subinventory(
                p_sub       => p_sub,
                p_org       => p_org,
                p_item      => p_item,
                p_acct_txn  => p_acct_txn);

   IF (l_result = INV_VALIDATE.T)
   THEN

     -- Make the call for inv_material_status_grp.is_status_applicable()
     -- with appropriate parameters
     l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                          p_wms_installed         => NULL,
                          p_trx_status_enabled    => NULL,
                          p_trx_type_id           => p_trx_type_id,
                          p_lot_status_enabled    => NULL,
                          p_serial_status_enabled => NULL,
                          p_organization_id       => p_org.organization_id,
                          p_inventory_item_id     => p_item.inventory_item_id,
                          p_sub_code              => p_sub.secondary_inventory_name,
                          p_locator_id            => NULL,
                          p_lot_number            => NULL,
                          p_serial_number         => NULL,
                          p_object_type           => p_object_type);

     -- If l_status_result = 'N', it means that the status validation has failed.
     -- Assign l_result = INV_VALIDATE.F and return l_result, else return l_result
     -- directly.
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     ELSE
       RETURN l_result;
     END IF;

   ELSE
     -- Basic From_subinventory validation has failed return l_result
     RETURN l_result;
   END IF;

END From_Subinventory;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Last_Updated_By ( p_last_updated_by IN NUMBER )
RETURN NUMBER
IS
l_dummy                            VARCHAR2(10);
BEGIN

   return check_creation_updation(p_last_updated_by, F);

END Last_Updated_By;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Last_Update_Date ( p_last_update_date IN DATE )
RETURN NUMBER
IS
BEGIN

      return check_date(p_last_update_date, 'DATE');

END Last_Update_Date;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Last_Update_Login ( p_last_update_login IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_update_login IS NULL OR
        p_last_update_login = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_update_login');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Login'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Login;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Organization (p_org IN OUT nocopy org)
RETURN NUMBER
IS

BEGIN

    IF (p_org.organization_id IS NULL AND p_org.organization_code IS NULL) OR
        p_org.organization_id = FND_API.G_MISS_NUM
    THEN
        RETURN F;
    END IF;

    IF (p_org.organization_id IS NOT NULL) THEN
       SELECT  *
    INTO    p_org
    FROM    MTL_PARAMETERS MP
    WHERE   ORGANIZATION_ID = p_org.organization_id;
       RETURN T;
     ELSE
       SELECT *
    INTO p_org
    FROM MTL_PARAMETERS MP
    WHERE MP.ORGANIZATION_CODE = p_org.organization_code
    AND MP.ORGANIZATION_ID = p_org.ORGANIZATION_ID;
       RETURN T;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_ORGCODE');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Program_Application ( p_program_application_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
     RETURN T;
END Program_Application;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Program ( p_program_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
     RETURN T;
END Program;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Program_Update_Date ( p_program_update_date IN DATE )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
     RETURN T;
END Program_Update_Date;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION To_Account ( p_to_account_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_account_id IS NULL OR
        p_to_account_id = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     GL_CODE_COMBINATIONS
    WHERE    CODE_COMBINATION_ID = p_to_account_id;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','ACCOUNT'),FALSE);
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Account;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION To_Subinventory ( p_sub IN OUT nocopy sub,
                           p_org IN ORG,
                           p_item IN ITEM,
                           p_from_sub IN SUB,
                           p_acct_txn IN NUMBER)
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
v_expense_to_asset_profile    VARCHAR2(1);
BEGIN

    IF p_sub.secondary_inventory_name IS NULL OR
        p_sub.secondary_inventory_name = FND_API.G_MISS_CHAR
    THEN
        RETURN T;
    END IF;
    FND_PROFILE.GET('INV:EXPENSE_TO_ASSET_TRANSFER',v_expense_to_asset_profile);
    if(nvl(v_expense_to_asset_profile,'2') = '1')
    then
      if(p_acct_txn <> 1)
      then
         if p_item.restrict_subinventories_code = 1
         then
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_ITEM_SUB_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND INVENTORY_ITEM_ID = p_item.inventory_item_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         else
            SELECT 'VALID'
            INTO   l_dummy
            FROM MTL_SUBINVENTORIES_VAL_V
            WHERE ORGANIZATION_ID = p_org.organization_id
              AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
         end if;
      end if;
    else
      if(p_acct_txn <> 1) then
         if p_item.restrict_subinventories_code = 1 then
            if p_item.inventory_asset_flag = 'Y' then
          if p_from_sub.asset_inventory is null then
        return T;
          elsif p_from_sub.asset_inventory = 1 then
                   SELECT 'VALID'
                   INTO   l_dummy
                   FROM MTL_ITEM_SUB_VAL_V
                   WHERE ORGANIZATION_ID = p_org.organization_id
                     AND INVENTORY_ITEM_ID = p_item.inventory_item_id
                     AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
               else
                 BEGIN
                   SELECT 'VALID'
                   INTO   l_dummy
                   FROM MTL_ITEM_SUB_EXP_VAL_V
                   WHERE ORGANIZATION_ID = p_org.organization_id
                     AND INVENTORY_ITEM_ID = p_item.inventory_item_id
                     AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('INV','INV_EXP_ACCT_REQ');
                    FND_MSG_PUB.Add;
                    return F;
                 END;
               end if;
            else
               SELECT 'VALID'
               INTO   l_dummy
               FROM MTL_ITEM_SUB_VAL_V
               WHERE ORGANIZATION_ID = p_org.organization_id
                 AND INVENTORY_ITEM_ID = p_item.inventory_item_id
                 AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
            end if;
         else
            if p_item.inventory_asset_flag = 'Y' then
          if p_from_sub.asset_inventory is null then
        return T;
               elsif p_from_sub.asset_inventory = 1 then
                  SELECT 'VALID'
                  INTO   l_dummy
                  FROM MTL_SUBINVENTORIES_VAL_V
                  WHERE ORGANIZATION_ID = p_org.organization_id
                    AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
               else
                 BEGIN
                  SELECT 'VALID'
                  INTO   l_dummy
                  FROM MTL_SUB_EXP_VAL_V
                  WHERE ORGANIZATION_ID = p_org.organization_id
                    AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('INV','INV_EXP_ACCT_REQ');
                    FND_MSG_PUB.Add;
                    return F;
                 END;
               end if;
            else
               SELECT 'VALID'
               INTO   l_dummy
               FROM MTL_SUBINVENTORIES_VAL_V
               WHERE ORGANIZATION_ID = p_org.organization_id
                 AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
            end if;
         end if;
      end if;
    end if;

    SELECT *
      INTO p_sub
      FROM MTL_SECONDARY_INVENTORIES
     WHERE ORGANIZATION_ID = p_org.organization_id
       AND SECONDARY_INVENTORY_NAME = p_sub.secondary_inventory_name;
    RETURN T;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_INT_XSUBCODE');
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Subinventory'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END To_Subinventory;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
/*
 * Bug# 6633612
 * Overloaded To_Subinventory function for Material Status Enhancement Project
 */
FUNCTION To_Subinventory ( p_sub IN OUT nocopy sub,
                           p_org IN ORG,
                           p_item IN ITEM,
                           p_from_sub IN SUB,
                           p_acct_txn IN NUMBER,
                           p_trx_type_id IN NUMBER, -- For Bug# 6633612
                           p_object_type IN VARCHAR2 DEFAULT 'Z' -- For Bug# 6633612
                         )
RETURN NUMBER
IS
l_result                   NUMBER;
l_status_result            VARCHAR2(1);
BEGIN

  /* First call the original To_Subinventory function,
   * If it returns INV_VALIDATE.T then goahead to call
   * inv_material_status_grp.is_status_applicable() function.
   */
  l_result := INV_VALIDATE.To_Subinventory(
                p_sub        => p_sub,
                p_org        => p_org,
                p_item       => p_item,
                p_from_sub   => p_from_sub,
                p_acct_txn   => p_acct_txn);

   IF (l_result = INV_VALIDATE.T)
   THEN

     -- Make the call for inv_material_status_grp.is_status_applicable()
     -- with appropriate parameters
     l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                          p_wms_installed         => NULL,
                          p_trx_status_enabled    => NULL,
                          p_trx_type_id           => p_trx_type_id,
                          p_lot_status_enabled    => NULL,
                          p_serial_status_enabled => NULL,
                          p_organization_id       => p_org.organization_id,
                          p_inventory_item_id     => p_item.inventory_item_id,
                          p_sub_code              => p_sub.secondary_inventory_name,
                          p_locator_id            => NULL,
                          p_lot_number            => NULL,
                          p_serial_number         => NULL,
                          p_object_type           => p_object_type);

     -- If l_status_result = 'N', it means that the status validation has failed.
     -- Assign l_result = INV_VALIDATE.F and return l_result, else return l_result
     -- directly.
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     ELSE
       RETURN l_result;
     END IF;

   ELSE
     -- Basic To_Subinventory validation has failed return l_result
     RETURN l_result;
   END IF;

END To_Subinventory;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Transaction_Type ( p_transaction_type_id IN NUMBER,
             x_transaction_action_id OUT NOCOPY NUMBER,
             x_transaction_source_type_id OUT NOCOPY NUMBER)
RETURN NUMBER
IS

BEGIN

    IF p_transaction_type_id IS NULL OR
        p_transaction_type_id = FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.SET_NAME('INV','INV_INT_TRXTYPCODE');
        FND_MSG_PUB.Add;
        RETURN F;
    END IF;

    SELECT transaction_action_id,transaction_source_type_id
      INTO x_transaction_action_id,x_transaction_source_type_id
      FROM mtl_transaction_types
      WHERE transaction_type_id = p_transaction_type_id;

    RETURN T;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

    FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');

    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','TRANSACTION'),FALSE);
    FND_MSG_PUB.Add;

      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
          ,   'Transaction_Type'
          );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      /*
      IF p_transaction_type_id IN (63,64) THEN
        RETURN T;
   ELSE
        RETURN F;
   END IF;
   */

END Transaction_Type;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Transaction_Type (x_transaction IN OUT nocopy transaction)RETURN NUMBER
IS

BEGIN

    IF x_transaction.transaction_type_id IS NULL OR
        x_transaction.transaction_type_id = FND_API.G_MISS_NUM
    THEN
        FND_MESSAGE.SET_NAME('INV','INV_INT_TRXTYPCODE');
        FND_MSG_PUB.Add;
        RETURN F;
    END IF;

    SELECT *
      INTO x_transaction
      FROM mtl_transaction_types
      WHERE transaction_type_id = x_transaction.transaction_type_id;

    RETURN T;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

    FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');

    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','TRANSACTION'),FALSE);
    FND_MSG_PUB.Add;

      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
          ,   'Transaction_Type'
          );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Type;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Check_Locator (p_locator      IN OUT nocopy locator,
                        p_org             IN ORG,
                        p_item            IN ITEM,
                        p_sub             IN SUB,
                        p_project_id      IN NUMBER,
                        p_task_id         IN NUMBER,
                        p_txn_action_id   IN number,
         p_is_from_locator in number,
                        p_dynamic_ok      IN BOOLEAN)

  RETURN NUMBER
  IS
     l_dummy                       VARCHAR2(10);
     l_return_status               VARCHAR2(10);
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(240);
     v_locator_control             NUMBER;
     l_number                      NUMBER;

BEGIN

   IF p_locator.inventory_location_id IS NULL OR
        p_locator.inventory_location_id = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;
    v_locator_control := INV_Globals.Locator_control(
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           p_org.stock_locator_control_code,
                           nvl(p_sub.locator_type,1),
                           p_item.location_control_code,
                           p_item.restrict_locators_code,
                           p_org.negative_inv_receipt_code,
                           p_txn_action_id);

    if(NVL(v_locator_control,1) = 2) then
       if (p_item.restrict_locators_code = 1) then  -- if restricted
          select *
          INTO   p_locator
          FROM   MTL_ITEM_LOCATIONS
          WHERE ORGANIZATION_ID = p_org.organization_id
            AND INVENTORY_LOCATION_ID = p_locator.inventory_location_id
            AND SUBINVENTORY_CODE = p_sub.secondary_inventory_name
            AND (DISABLE_DATE > SYSDATE OR DISABLE_DATE IS NULL)
            AND INVENTORY_LOCATION_ID IN
                  (SELECT  SECONDARY_LOCATOR
                     FROM  MTL_SECONDARY_LOCATORS
                    WHERE INVENTORY_ITEM_ID = p_item.inventory_item_id
                      AND ORGANIZATION_ID = p_org.organization_id
                      AND NVL(PROJECT_ID,-1) = NVL(p_project_id,-1)
                      AND NVL(TASK_ID,-1) = NVL(p_task_id,-1)
                      AND SUBINVENTORY_CODE = p_sub.secondary_inventory_name);
   else
         SELECT *
         INTO   p_locator
         FROM   MTL_ITEM_LOCATIONS
         WHERE ORGANIZATION_ID = p_org.organization_id
           AND INVENTORY_LOCATION_ID = p_locator.inventory_location_id
           AND (NVL(SUBINVENTORY_CODE,p_sub.secondary_inventory_name) =
                      p_sub.secondary_inventory_name)
           AND (DISABLE_DATE > SYSDATE OR DISABLE_DATE IS NULL)
           AND NVL(PROJECT_ID,-1) = NVL(p_project_id,-1)
           AND NVL(TASK_ID,-1) = NVL(p_task_id,-1);
       end if;
    elsif NVL(v_locator_control,1) = 3 then -- if dynamic
         SELECT *
         INTO   p_locator
         FROM   MTL_ITEM_LOCATIONS
         WHERE  ORGANIZATION_ID = p_org.organization_id
           AND INVENTORY_LOCATION_ID = p_locator.inventory_location_id
           AND (NVL(SUBINVENTORY_CODE,p_sub.secondary_inventory_name) =
                                p_sub.secondary_inventory_name)
           AND (DISABLE_DATE > SYSDATE OR DISABLE_DATE IS NULL)
           AND NVL(PROJECT_ID,-1) = NVL(p_project_id,-1)
           AND NVL(TASK_ID,-1) = NVL(p_task_id,-1);
    end if;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       if v_locator_control = 3 and p_dynamic_ok THEN
     l_number := validateLocator(p_locator,p_org,p_sub,EXISTS_OR_CREATE);
     RETURN l_number;
       end if;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN

     FND_MESSAGE.SET_NAME('INV','INV_INT_LOCCODE');
     FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
      if (p_is_from_locator = 1)
        then
         FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
          ,   'From_Locator'
          );
       else
         FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
          ,   'To_Locator'
          );
      end if;
   END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_locator;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION From_Locator ( p_locator IN OUT nocopy locator,
                        p_org             IN ORG,
                        p_item            IN ITEM,
                        p_from_sub        IN SUB,
                        p_project_id      IN NUMBER,
                        p_task_id         IN NUMBER,
                        p_txn_action_id   IN NUMBER)

  RETURN NUMBER
  IS

BEGIN

     Return check_locator(p_locator,
                p_org, p_item,p_from_sub,
                p_project_id, p_task_id,
                p_txn_action_id, t, false);

END From_Locator;


-- generate the concatenated segment given the application short name like
-- 'INV' OR 'FND' AND the key flex field code LIKE 'MTLL' and the structure
-- NUMBER LIKE 101
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION concat_segments(p_appl_short_name IN VARCHAR2,
          p_key_flex_code IN VARCHAR2,
          p_structure_number IN NUMBER)
  RETURN VARCHAR2
  IS

     l_key_flex_field   fnd_flex_key_api.flexfield_type;
     l_structure_type   fnd_flex_key_api.structure_type;
     l_segment_type     fnd_flex_key_api.segment_type;
     l_segment_list     fnd_flex_key_api.segment_list;
     l_segment_array    fnd_flex_ext.SegmentArray;
     l_num_segments     NUMBER;
     l_flag             BOOLEAN;
     l_concat           VARCHAR2(2000);
     j                  NUMBER;
     i                  NUMBER;
BEGIN

   fnd_flex_key_api.set_session_mode('seed_data');

   l_key_flex_field :=
     fnd_flex_key_api.find_flexfield(p_appl_short_name,
                 p_key_flex_code);

   l_structure_type :=
     fnd_flex_key_api.find_structure(l_key_flex_field,
                 p_structure_number);

   fnd_flex_key_api.get_segments(l_key_flex_field, l_structure_type,
             TRUE, l_num_segments, l_segment_list);


   --
   -- The segments in the seg_list array are sorted in display order.
   -- i.e. sorted by segment number.
   --
   for i in 1..l_num_segments loop
      l_segment_type :=
   fnd_flex_key_api.find_segment(l_key_flex_field,
                  l_structure_type,
                  l_segment_list(i));
      j := to_number(substr(l_segment_type.column_name,8));
      l_segment_array(i) := g_kf_segment_values(j);
   end loop;

   --
   -- Now we have the all segment values in correct order in segarray.
   --
   l_concat := fnd_flex_ext.concatenate_segments(l_num_segments,
                   l_segment_array,
                  l_structure_type.segment_separator);

   RETURN l_concat;


END concat_segments;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Inventory_Item (p_item IN OUT nocopy item, p_org IN org)
RETURN NUMBER
IS
   l_appl_short_name VARCHAR2(3) := 'INV';
   l_key_flex_code VARCHAR2(4) := 'MSTK';
   l_structure_number NUMBER := 101;
   l_conc_segments VARCHAR2(2000);
   l_keystat_val BOOLEAN;
   l_id                 NUMBER;
   l_validation_mode VARCHAR2(25) := EXISTS_ONLY;

BEGIN

--    IF (p_item.inventory_item_id IS NULL OR
--        p_item.inventory_item_id = FND_API.g_miss_num) AND
--      p_validation_mode IS NULL
--    THEN
--        RETURN F;
--    END IF;

    IF p_item.inventory_item_id IS NULL THEN
       g_kf_segment_values(1) := p_item.segment1;
       g_kf_segment_values(2) := p_item.segment2;
       g_kf_segment_values(3) := p_item.segment3;
       g_kf_segment_values(4) := p_item.segment4;
       g_kf_segment_values(5) := p_item.segment5;
       g_kf_segment_values(6) := p_item.segment6;
       g_kf_segment_values(7) := p_item.segment7;
       g_kf_segment_values(8) := p_item.segment8;
       g_kf_segment_values(9) := p_item.segment9;
       g_kf_segment_values(10) := p_item.segment10;
       g_kf_segment_values(11) := p_item.segment11;
       g_kf_segment_values(12) := p_item.segment12;
       g_kf_segment_values(13) := p_item.segment13;
       g_kf_segment_values(14) := p_item.segment14;
       g_kf_segment_values(15) := p_item.segment15;
       g_kf_segment_values(16) := p_item.segment16;
       g_kf_segment_values(17) := p_item.segment17;
       g_kf_segment_values(18) := p_item.segment18;
       g_kf_segment_values(19) := p_item.segment19;
       g_kf_segment_values(20) := p_item.segment20;

       l_conc_segments := concat_segments(l_appl_short_name,
                 l_key_flex_code,
                 l_structure_number);

       l_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                            OPERATION        => l_validation_mode,
                            APPL_SHORT_NAME  => l_appl_short_name,
                            KEY_FLEX_CODE    => l_key_flex_code,
                            STRUCTURE_NUMBER => l_structure_number,
                            CONCAT_SEGMENTS  => l_conc_segments,
                            VALUES_OR_IDS    => 'V',
                            DATA_SET         => p_org.organization_id
                         );

       IF (l_keystat_val = FALSE) THEN
     RETURN F;
   ELSE
     l_id := FND_FLEX_KEYVAL.combination_id;
     p_item.inventory_item_id := l_id;
       END IF;
    END IF;

    SELECT  *
      INTO    p_item
      FROM    MTL_SYSTEM_ITEMS
      WHERE   ORGANIZATION_ID = p_org.organization_id
      AND   INVENTORY_ITEM_ID = p_item.inventory_item_id;

    IF p_item.mtl_transactions_enabled_flag = 'Y'
    THEN
       RETURN T;
    ELSE
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
          FND_MESSAGE.SET_NAME('INV','INV_ITEM_TXNS_NOT_ENABLED');
          FND_MSG_PUB.Add;
       END IF;
       RETURN F;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_ITMCODE');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

/***Added overloaded function to pass the transaction_type_id, because
we are allowing delivery of PO receipt for expense items as part of this bug***/
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Inventory_Item (p_item IN OUT nocopy item, p_org IN org, p_transaction_type IN NUMBER)--bug9267446
RETURN NUMBER
IS
   l_appl_short_name VARCHAR2(3) := 'INV';
   l_key_flex_code VARCHAR2(4) := 'MSTK';
   l_structure_number NUMBER := 101;
   l_conc_segments VARCHAR2(2000);
   l_keystat_val BOOLEAN;
   l_id                 NUMBER;
   l_validation_mode VARCHAR2(25) := EXISTS_ONLY;

BEGIN

--    IF (p_item.inventory_item_id IS NULL OR
--        p_item.inventory_item_id = FND_API.g_miss_num) AND
--      p_validation_mode IS NULL
--    THEN
--        RETURN F;
--    END IF;

    IF p_item.inventory_item_id IS NULL THEN
       g_kf_segment_values(1) := p_item.segment1;
       g_kf_segment_values(2) := p_item.segment2;
       g_kf_segment_values(3) := p_item.segment3;
       g_kf_segment_values(4) := p_item.segment4;
       g_kf_segment_values(5) := p_item.segment5;
       g_kf_segment_values(6) := p_item.segment6;
       g_kf_segment_values(7) := p_item.segment7;
       g_kf_segment_values(8) := p_item.segment8;
       g_kf_segment_values(9) := p_item.segment9;
       g_kf_segment_values(10) := p_item.segment10;
       g_kf_segment_values(11) := p_item.segment11;
       g_kf_segment_values(12) := p_item.segment12;
       g_kf_segment_values(13) := p_item.segment13;
       g_kf_segment_values(14) := p_item.segment14;
       g_kf_segment_values(15) := p_item.segment15;
       g_kf_segment_values(16) := p_item.segment16;
       g_kf_segment_values(17) := p_item.segment17;
       g_kf_segment_values(18) := p_item.segment18;
       g_kf_segment_values(19) := p_item.segment19;
       g_kf_segment_values(20) := p_item.segment20;

       l_conc_segments := concat_segments(l_appl_short_name,
                 l_key_flex_code,
                 l_structure_number);

       l_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                            OPERATION        => l_validation_mode,
                            APPL_SHORT_NAME  => l_appl_short_name,
                            KEY_FLEX_CODE    => l_key_flex_code,
                            STRUCTURE_NUMBER => l_structure_number,
                            CONCAT_SEGMENTS  => l_conc_segments,
                            VALUES_OR_IDS    => 'V',
                            DATA_SET         => p_org.organization_id
                         );

       IF (l_keystat_val = FALSE) THEN
     RETURN F;
   ELSE
     l_id := FND_FLEX_KEYVAL.combination_id;
     p_item.inventory_item_id := l_id;
       END IF;
    END IF;

    SELECT  *
      INTO    p_item
      FROM    MTL_SYSTEM_ITEMS
      WHERE   ORGANIZATION_ID = p_org.organization_id
      AND   INVENTORY_ITEM_ID = p_item.inventory_item_id;


    IF p_item.mtl_transactions_enabled_flag = 'Y'
    THEN
       RETURN T;
     /* bug9267446 */
     ELSIF p_transaction_type=18 THEN
	RETURN T;
     /* bug9267446 */
     ELSE
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
          FND_MESSAGE.SET_NAME('INV','INV_ITEM_TXNS_NOT_ENABLED');
          FND_MSG_PUB.Add;
       END IF;
       RETURN F;
    END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_ITMCODE');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION validateLocator(p_locator IN OUT nocopy locator,
          p_org IN org,
          p_sub IN sub,
          p_validation_mode IN VARCHAR2 DEFAULT EXISTS_ONLY,
          p_value_or_id IN VARCHAR2 DEFAULT 'V')
  RETURN NUMBER
  IS
   l_appl_short_name VARCHAR2(3) := 'INV';
   l_key_flex_code VARCHAR2(4) := 'MTLL';
   l_structure_number NUMBER := 101;
   l_conc_segments VARCHAR2(2000);
   l_keystat_val BOOLEAN;
   l_id                 NUMBER;

BEGIN

-- Bug 2733385, setting the MFG_ORGANIZATION_ID profile value.
   if (g_orgid is null or g_orgid <> p_org.organization_id) then
      fnd_profile.put('MFG_ORGANIZATION_ID',p_org.organization_id);
      g_orgid := p_org.organization_id;
   end if;

   IF (p_locator.inventory_location_id IS NULL OR
       p_locator.inventory_location_id = FND_API.g_miss_num)
   THEN
      g_kf_segment_values(1) := p_locator.segment1;
      g_kf_segment_values(2) := p_locator.segment2;
      g_kf_segment_values(3) := p_locator.segment3;
      g_kf_segment_values(4) := p_locator.segment4;
      g_kf_segment_values(5) := p_locator.segment5;
      g_kf_segment_values(6) := p_locator.segment6;
      g_kf_segment_values(7) := p_locator.segment7;
      g_kf_segment_values(8) := p_locator.segment8;
      g_kf_segment_values(9) := p_locator.segment9;
      g_kf_segment_values(10) := p_locator.segment10;
      g_kf_segment_values(11) := p_locator.segment11;
      g_kf_segment_values(12) := p_locator.segment12;
      g_kf_segment_values(13) := p_locator.segment13;
      g_kf_segment_values(14) := p_locator.segment14;
      g_kf_segment_values(15) := p_locator.segment15;
      g_kf_segment_values(16) := p_locator.segment16;
      g_kf_segment_values(17) := p_locator.segment17;
      g_kf_segment_values(18) := p_locator.segment18;
      g_kf_segment_values(19) := p_locator.segment19;
      g_kf_segment_values(20) := p_locator.segment20;

      l_conc_segments := concat_segments(l_appl_short_name,
                l_key_flex_code,
                l_structure_number);

      --inv_debug.message('l_conc_segments is ' || l_conc_segments);

      l_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                            OPERATION        => p_validation_mode,
                            APPL_SHORT_NAME  => l_appl_short_name,
                            KEY_FLEX_CODE    => l_key_flex_code,
                            STRUCTURE_NUMBER => l_structure_number,
                            CONCAT_SEGMENTS  => l_conc_segments,
                            VALUES_OR_IDS    => p_value_or_id,
                            DATA_SET         => p_org.organization_id
                         );
      IF (l_keystat_val = FALSE) THEN
    RETURN F;
       ELSE
    l_id := FND_FLEX_KEYVAL.combination_id;
   --inv_debug.message('l_id is ' || l_id);
    p_locator.inventory_location_id := l_id;
    if(p_validation_mode = EXISTS_OR_CREATE
       AND FND_FLEX_KEYVAL.new_combination)
           then
       --inv_debug.message('new combination');
       UPDATE mtl_item_locations
         SET subinventory_code = p_sub.secondary_inventory_name
         ,project_id = p_locator.project_id
         ,task_id = p_locator.task_id
         ,physical_location_id = p_locator.physical_location_id
         ,inventory_location_type = p_locator.inventory_location_type
         WHERE organization_id = p_org.organization_id
         AND inventory_location_id = p_locator.inventory_location_id;
    end if;
      END IF;

   END IF;

   SELECT *
     INTO p_locator
     FROM mtl_item_locations
     WHERE organization_id = p_org.organization_id
     AND subinventory_code = p_sub.secondary_inventory_name
     AND inventory_location_id = p_locator.inventory_location_id
     AND NVL(disable_date,SYSDATE) >= SYSDATE;

   RETURN T;

EXCEPTION

   WHEN no_data_found THEN
      --inv_debug.message('no data found');
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
    fnd_message.set_name('INV','INV_INT_LOCCODE');
    fnd_msg_pub.Add;
      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
    fnd_msg_pub.add_exc_msg(g_pkg_name, 'validateLocator:org,sub');
      END IF;
--      RETURN f;
      RAISE fnd_api.g_exc_unexpected_error;

END validateLocator;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION validateLocator(p_locator IN OUT nocopy locator,
       p_org IN org,
                 p_sub IN sub,
       p_item IN item)
  RETURN NUMBER
  IS
BEGIN
     IF p_locator.inventory_location_id IS NULL OR
       p_locator.inventory_location_id = FND_API.G_MISS_NUM
       THEN
        RETURN F;
     END IF;

     if(p_item.restrict_locators_code <> 1) then
       return validateLocator(p_locator,p_org,p_sub);
     end if;

     SELECT mil.*
       INTO p_locator
       FROM mtl_item_locations mil,mtl_secondary_locators msl
       WHERE mil.organization_id = p_org.organization_id
       AND mil.subinventory_code = p_sub.secondary_inventory_name
       AND mil.inventory_location_id = p_locator.inventory_location_id
       AND NVL(disable_date,SYSDATE) >= SYSDATE
       AND mil.organization_id = msl.organization_id
       AND mil.subinventory_code = msl.subinventory_code
       AND mil.inventory_location_id = msl.secondary_locator
       AND msl.inventory_item_id = p_item.inventory_item_id;

     RETURN T;

EXCEPTION

   WHEN no_data_found THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
    fnd_message.set_name('INV','INV_CCEOI_LOC_NOT_IN_LIST');
    fnd_msg_pub.Add;
      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
    fnd_msg_pub.add_exc_msg(g_pkg_name, 'validateLocator:org,sub,item');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;

END validateLocator;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
/*
 * Bug# 6633612
 * Overloaded validateLocator function for Material Status Enhancement Project
 */
FUNCTION validateLocator( p_locator IN OUT nocopy locator,
                          p_org IN org,
                          p_sub IN sub,
                          p_item IN item,
                          p_trx_type_id IN NUMBER, -- For Bug# 6633612
                          p_object_type IN VARCHAR2 DEFAULT 'L' -- For Bug# 6633612
                        )
RETURN NUMBER
IS
l_result                   NUMBER;
l_status_result            VARCHAR2(1);
BEGIN
  /* First call the original validateLocator function,
   * If it returns INV_VALIDATE.T then goahead to call
   * inv_material_status_grp.is_status_applicable() function.
   */
  l_result := INV_VALIDATE.validateLocator(
                p_locator  => p_locator,
                p_org      => p_org,
                p_sub      => p_sub,
                p_item     => p_item);

  IF (l_result = INV_VALIDATE.T)
  THEN

    -- Make the call for inv_material_status_grp.is_status_applicable()
    -- with appropriate parameters
    l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                         p_wms_installed         => NULL,
                         p_trx_status_enabled    => NULL,
                         p_trx_type_id           => p_trx_type_id,
                         p_lot_status_enabled    => NULL,
                         p_serial_status_enabled => NULL,
                         p_organization_id       => p_org.organization_id,
                         p_inventory_item_id     => p_item.inventory_item_id,
                         p_sub_code              => p_sub.secondary_inventory_name,
                         p_locator_id            => p_locator.inventory_location_id,
                         p_lot_number            => NULL,
                         p_serial_number         => NULL,
                         p_object_type           => p_object_type);

     -- If l_status_result = 'N', it means that the status validation has failed.
     -- Assign l_result = INV_VALIDATE.F and return l_result, else return l_result
     -- directly.
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     ELSE
       RETURN l_result;
     END IF;

   ELSE
     -- Basic validateLocator validation has failed return l_result
     RETURN l_result;
   END IF;

END validateLocator;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Lot_Number ( p_lot IN OUT nocopy lot,
            p_org IN ORG,
            p_item IN ITEM,
            p_from_sub IN sub,
            p_loc IN LOCATOR,
            p_revision in VARCHAR
            )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);

BEGIN
    IF p_lot.lot_number IS NULL OR
        p_lot.lot_number = FND_API.G_MISS_CHAR
    THEN
        RETURN T;
    END IF;

    IF p_item.lot_control_code = 1  THEN
        FND_MESSAGE.SET_NAME('INV','INV_NO_LOT_CONTROL');
        FND_MSG_PUB.Add;
        RETURN F;
    END IF;

    SELECT mln.*
      INTO p_lot
      FROM MTL_LOT_NUMBERS MLN
     WHERE MLN.INVENTORY_ITEM_ID = p_item.inventory_item_id
       AND MLN.ORGANIZATION_ID = p_org.organization_id
       AND MLN.LOT_NUMBER = p_lot.lot_number
       AND MLN.LOT_NUMBER IN (SELECT LOT_NUMBER
                                FROM MTL_ONHAND_QUANTITIES_DETAIL MOQ
                               WHERE MOQ.INVENTORY_ITEM_ID = p_item.inventory_item_id
                                 AND MOQ.ORGANIZATION_ID = p_org.organization_id
                                 AND MOQ.LOT_NUMBER = p_lot.lot_number
                                 AND MOQ.SUBINVENTORY_CODE =
                                      NVL(p_from_sub.secondary_inventory_name,'##')
                                 AND NVL(MOQ.REVISION,'##') = NVL(p_revision,'##')
                                 AND NVL(MOQ.LOCATOR_ID,-1) = NVL(p_loc.inventory_location_id,-1)
                                 AND ROWNUM < 2);

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','CAPS_LOT_NUMBER'),FALSE);
            FND_MSG_PUB.Add;

        END IF;
        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Number;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
/*
 * Bug# 6633612
 * Overloaded Lot_Number function for Material Status Enhancement Project
 */
FUNCTION Lot_Number ( p_lot IN OUT nocopy lot,
                      p_org IN ORG,
                      p_item IN ITEM,
                      p_from_sub IN sub,
                      p_loc IN LOCATOR,
                      p_revision in VARCHAR,
                      p_trx_type_id IN NUMBER, -- For Bug# 6633612
                      p_object_type IN VARCHAR2 DEFAULT 'O' -- For Bug# 6633612
                    )
RETURN NUMBER
IS
l_result                   NUMBER;
l_status_result            VARCHAR2(1);
BEGIN
  /* First call the original Lot_Number function,
   * If it returns INV_VALIDATE.T then goahead to call
   * inv_material_status_grp.is_status_applicable() function.
   */
  l_result := INV_VALIDATE.Lot_Number(
                p_lot       => p_lot,
                p_org       => p_org,
                p_item      => p_item,
                p_from_sub  => p_from_sub,
                p_loc       => p_loc,
                p_revision  => p_revision);

  IF (l_result = INV_VALIDATE.T)
  THEN

    -- Make the call for inv_material_status_grp.is_status_applicable()
    -- with appropriate parameters
    l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                         p_wms_installed         => NULL,
                         p_trx_status_enabled    => NULL,
                         p_trx_type_id           => p_trx_type_id,
                         p_lot_status_enabled    => NULL,
                         p_serial_status_enabled => NULL,
                         p_organization_id       => p_org.organization_id,
                         p_inventory_item_id     => p_item.inventory_item_id,
                         p_sub_code              => p_from_sub.secondary_inventory_name,
                         p_locator_id            => p_loc.inventory_location_id,
                         p_lot_number            => p_lot.lot_number,
                         p_serial_number         => NULL,
                         p_object_type           => p_object_type);

     -- If l_status_result = 'N', it means that the status validation has failed.
     -- Assign l_result = INV_VALIDATE.F and return l_result, else return l_result
     -- directly.
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     ELSE
       RETURN l_result;
     END IF;

   ELSE
     -- Basic Lot_Number validation has failed return l_result
     RETURN l_result;
   END IF;

END Lot_Number;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Project ( p_project_id IN NUMBER )
  RETURN NUMBER
  IS
     l_dummy                       VARCHAR2(10);
     l_organization_id             NUMBER;
BEGIN

   IF p_project_id IS NULL OR
     p_project_id = FND_API.G_MISS_NUM
     THEN
      RETURN T;
   END IF;

   SELECT  'VALID'
     INTO     l_dummy
     FROM    PJM_PROJECTS_V
     WHERE   PROJECT_ID = p_project_id;

   RETURN T;

     EXCEPTION

     WHEN NO_DATA_FOUND THEN

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     THEN

     FND_MESSAGE.SET_NAME('INV','INV_PRJ_ERR');
     FND_MSG_PUB.Add;

     END IF;

     RETURN F;

     WHEN OTHERS THEN

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
     FND_MSG_PUB.Add_Exc_Msg
     (   G_PKG_NAME
     ,   'Project'
     );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Quantity ( p_quantity IN NUMBER )
RETURN NUMBER
IS
BEGIN
     IF p_quantity IS NULL OR
        p_quantity = FND_API.G_MISS_NUM
     THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_INT_QTYCODE');
            FND_MSG_PUB.Add;
        END IF;
        return F;
     END IF;
     RETURN T;
END Quantity;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Reason ( p_reason_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reason_id IS NULL OR
        p_reason_id = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MTL_TRANSACTION_REASONS
    WHERE   NVL(DISABLE_DATE,SYSDATE) >= SYSDATE
      AND   REASON_ID = p_reason_id;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_REACODE');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reason;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Reference ( p_reference IN VARCHAR2 )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
     RETURN T;
END Reference;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Reference ( p_reference_id IN NUMBER, p_reference_type_code IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reference_id IS NULL OR
        p_reference_id = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    IF p_reference_type_code = INV_Transfer_Order_PVT.G_Ref_type_Kanban
    THEN
      SELECT  'VALID'
      INTO    l_dummy
      FROM    MTL_KANBAN_CARDS
      WHERE   EXISTS (SELECT 1
                      FROM    MFG_LOOKUPS
                      WHERE   LOOKUP_TYPE = 'MTL_TXN_REQUEST_SOURCE'
                        AND   LOOKUP_CODE = p_reference_type_code)
        AND  KANBAN_CARD_ID = p_reference_id;
      END IF;
    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_REFERENCE_ID'),FALSE); -- ND
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Reference_Type ( p_reference_type_code IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reference_type_code IS NULL OR
        p_reference_type_code = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MFG_LOOKUPS
    WHERE   LOOKUP_TYPE = 'MTL_TXN_REQUEST_SOURCE'
      AND   LOOKUP_CODE = p_reference_type_code;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_REFERENCE_TYPE'),FALSE); -- ND;
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Type;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Revision ( p_revision IN VARCHAR2, p_org IN ORG, p_item IN ITEM )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_revision IS NULL OR
        p_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN T;
    END IF;

    IF p_item.revision_qty_control_code = 1  THEN
        FND_MESSAGE.SET_NAME('INV','INV_NO_REVISION_CONTROL'); -- ND
        FND_MSG_PUB.Add;
        RETURN F;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM MTL_ITEM_REVISIONS
    WHERE ORGANIZATION_ID = p_org.organization_id
      AND INVENTORY_ITEM_ID = p_item.inventory_item_id
      AND REVISION = p_revision;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INT_REVCODE');
            FND_MSG_PUB.Add;

        END IF;
        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg

            (   G_PKG_NAME
            ,   'Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
function check_serial( p_serial IN OUT nocopy serial,
             p_org IN ORG,
             p_item IN ITEM,
             p_from_sub IN sub,
             p_lot in lot,
             p_loc in locator,
             p_revision in VARCHAR2,
             p_msg IN VARCHAR2,
             p_txn_type_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER
  IS
     l_dummy                       VARCHAR2(10);

BEGIN

   IF p_serial.serial_number IS NULL OR
     p_serial.serial_number = FND_API.G_MISS_CHAR
     THEN
      RETURN T;
   END IF;

   IF p_item.serial_number_control_code = 1
      AND inv_cache.get_serial_tagged(p_org.organization_id
                                    , p_item.inventory_item_id
                                    , p_txn_type_id) = 1
   THEN
      FND_MESSAGE.SET_NAME('INV','INV_ITEM_NOT_SERIAL_CONTROLLED');
      FND_MSG_PUB.Add;
      RETURN F;
   END IF;

   IF p_item.serial_number_control_code = 2 THEN

      -- Bug# 7149590
      -- Removed the condition AND (GROUP_MARK_ID IS NULL OR GROUP_MARK_ID = -1)
      -- because while ship confirming predefined serials, the group_mark_id is
      -- still not null and is stamped with a valid value.
      SELECT  *
      INTO  p_serial
      FROM    MTL_SERIAL_NUMBERS
      WHERE INVENTORY_ITEM_ID = p_item.inventory_item_id
      AND CURRENT_ORGANIZATION_ID = p_org.organization_id
      AND SERIAL_NUMBER = p_serial.serial_number
      AND ((NVL(CURRENT_SUBINVENTORY_CODE,'@@@') =
      NVL(p_from_sub.secondary_inventory_name,'@@@')
      AND NVL(CURRENT_LOCATOR_ID,-1)=NVL(p_loc.inventory_location_id,-1)
      AND NVL(LOT_NUMBER,'@@@') = NVL(p_lot.lot_number,'@@@')
      AND NVL(REVISION,'@@@') = NVL(p_revision,'@@@')
      AND CURRENT_STATUS = 3));

   RETURN T;
    ELSE
      -- serial number control code should be equal to 5 or 6,
      -- both are dynamically generated serial numbers
      -- Bug# 6898243
      -- Ship confirmation was failing for lot + serial @ SO Issue control. This was occuring
      -- because at the time of Ship Confirm the serial would be present in status 1
      -- and in this status, lot_number will NOT be stamped in MSN.
      -- Status 1 or 6 serials will not have lot/revision stamped in MSN.

      SELECT  *
      INTO  p_serial
      FROM    MTL_SERIAL_NUMBERS
      WHERE INVENTORY_ITEM_ID = p_item.inventory_item_id
      AND CURRENT_ORGANIZATION_ID = p_org.organization_id
      AND SERIAL_NUMBER = p_serial.serial_number
      AND (CURRENT_STATUS IN (1,6) OR NVL(LOT_NUMBER,'@@@') = NVL(p_lot.lot_number,'@@@'))
      AND (CURRENT_STATUS IN (1,6) OR NVL(REVISION,'@@@') = NVL(p_revision,'@@@'))
      AND CURRENT_STATUS IN (1, 3, 6,4);  --9113242 Added current_status 4

      -- End Bug# 6898243

   RETURN T;
   END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

    FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV',p_msg),FALSE); -- ND

    FND_MSG_PUB.Add;

      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
          ,   'Check_serial_number'
          );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end check_serial;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Validate_serial ( p_serial IN OUT nocopy serial,
            p_org IN ORG,
            p_item IN ITEM,
            p_from_sub IN sub,
            p_lot in lot,
            p_loc in locator,
            p_revision in VARCHAR2,
            p_txn_type_id IN NUMBER DEFAULT NULL)
RETURN NUMBER
  IS

BEGIN

   return check_serial(p_serial,p_org,p_item,p_from_sub,
                p_lot,p_loc, p_revision,
                'CAPS_SERIAL_NUMBER', p_txn_type_id);

END Validate_serial;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
/*
 * Bug# 6633612
 * Overloaded Validate_serial function for Material Status Enhancement Project
 */
FUNCTION Validate_serial ( p_serial IN OUT nocopy serial,
                           p_org IN ORG,
                           p_item IN ITEM,
                           p_from_sub IN sub,
                           p_lot in lot,
                           p_loc in locator,
                           p_revision in VARCHAR2,
                           p_trx_type_id IN NUMBER, -- For Bug# 6633612
                           p_object_type IN VARCHAR2 DEFAULT 'S' -- For Bug# 6633612
                         )
RETURN NUMBER
IS
l_result                   NUMBER;
l_status_result            VARCHAR2(1);
BEGIN
  /* First call the original Validate_serial function,
   * If it returns INV_VALIDATE.T then goahead to call
   * inv_material_status_grp.is_status_applicable() function.
   */
  l_result := INV_VALIDATE.Validate_serial(
                p_serial    => p_serial,
                p_org       => p_org,
                p_item      => p_item,
                p_from_sub  => p_from_sub,
                p_lot       => p_lot,
                p_loc       => p_loc,
                p_revision  => p_revision,
                p_txn_type_id => p_trx_type_id);

  IF (l_result = INV_VALIDATE.T)
  THEN

    -- Make the call for inv_material_status_grp.is_status_applicable()
    -- with appropriate parameters
    l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                         p_wms_installed         => NULL,
                         p_trx_status_enabled    => NULL,
                         p_trx_type_id           => p_trx_type_id,
                         p_lot_status_enabled    => NULL,
                         p_serial_status_enabled => NULL,
                         p_organization_id       => p_org.organization_id,
                         p_inventory_item_id     => p_item.inventory_item_id,
                         p_sub_code              => p_from_sub.secondary_inventory_name,
                         p_locator_id            => p_loc.inventory_location_id,
                         p_lot_number            => p_lot.lot_number,
                         p_serial_number         => p_serial.serial_number,
                         p_object_type           => p_object_type);

     -- If l_status_result = 'N', it means that status validation has failed.
     -- Assign l_result = INV_VALIDATE.F and return l_result, else return l_result
     -- directly.
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     ELSE
       RETURN l_result;
     END IF;

   ELSE
     -- Basic Validate_serial validation has failed return l_result
     RETURN l_result;
   END IF;

END Validate_serial;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

/*
 * Bug# 6633612
 * Validate_serial_range function for Material Status Enhancement Project
 */

FUNCTION validate_serial_range(p_fm_serial IN OUT nocopy SERIAL_NUMBER_TBL,
                               p_to_serial IN OUT nocopy SERIAL_NUMBER_TBL,
                               p_org in ORG,
                               p_item IN ITEM,
                               p_from_sub IN sub,
                               p_lot in lot,
                               p_loc in locator,
                               p_revision in VARCHAR2,
                               p_trx_type_id IN NUMBER, -- For Bug# 6633612
                               p_object_type IN VARCHAR2 DEFAULT 'S', -- For Bug# 6633612
                               x_errored_serials OUT nocopy SERIAL_NUMBER_TBL -- For Bug# 6633612
                              )
RETURN NUMBER
IS
l_result              NUMBER;
l_status_result       VARCHAR2(1);

l_prefix              VARCHAR2(30);
l_quantity            NUMBER;
l_from_number         VARCHAR2(30);
l_to_number           VARCHAR2(30);
l_errorcode           NUMBER;
l_number_part         NUMBER := 0;
l_counter             NUMBER := 0;
l_length              NUMBER;
l_padded_length       NUMBER;
l_temp_serial         serial;
l_errored_serial_count  NUMBER := 0;

BEGIN

  -- From and To Serial is not of the same size return with INV_VALIDATE.F.
  IF((p_fm_serial IS NULL) OR (p_to_serial IS NULL) OR (p_fm_serial.LAST <> p_to_serial.LAST)) THEN
    l_result := INV_VALIDATE.F;
    RETURN l_result;
  END IF;

  -- Check for the material status of sub,locator and lot if p_object_type = 'A'.
  IF (p_object_type = 'A') THEN
    -- Make the call for inv_material_status_grp.is_status_applicable()
    -- with appropriate parameters
    IF (p_from_sub.secondary_inventory_name IS NOT NULL) THEN
      l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                           p_wms_installed         => NULL,
                           p_trx_status_enabled    => NULL,
                           p_trx_type_id           => p_trx_type_id,
                           p_lot_status_enabled    => NULL,
                           p_serial_status_enabled => NULL,
                           p_organization_id       => p_org.organization_id,
                           p_inventory_item_id     => p_item.inventory_item_id,
                           p_sub_code              => p_from_sub.secondary_inventory_name,
                           p_locator_id            => NULL,
                           p_lot_number            => NULL,
                           p_serial_number         => NULL,
                           p_object_type           => 'Z');
     -- Subinventory status validation has failed
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     END IF;
    END IF;

    IF (p_loc.inventory_location_id IS NOT NULL) THEN
      l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                           p_wms_installed         => NULL,
                           p_trx_status_enabled    => NULL,
                           p_trx_type_id           => p_trx_type_id,
                           p_lot_status_enabled    => NULL,
                           p_serial_status_enabled => NULL,
                           p_organization_id       => p_org.organization_id,
                           p_inventory_item_id     => p_item.inventory_item_id,
                           p_sub_code              => p_from_sub.secondary_inventory_name,
                           p_locator_id            => p_loc.inventory_location_id,
                           p_lot_number            => NULL,
                           p_serial_number         => NULL,
                           p_object_type           => 'L');
     -- Locator status validation has failed
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     END IF;
    END IF;

    IF (p_lot.lot_number IS NOT NULL) THEN
      l_status_result := INV_MATERIAL_STATUS_GRP.is_status_applicable(
                           p_wms_installed         => NULL,
                           p_trx_status_enabled    => NULL,
                           p_trx_type_id           => p_trx_type_id,
                           p_lot_status_enabled    => NULL,
                           p_serial_status_enabled => NULL,
                           p_organization_id       => p_org.organization_id,
                           p_inventory_item_id     => p_item.inventory_item_id,
                           p_sub_code              => p_from_sub.secondary_inventory_name,
                           p_locator_id            => p_loc.inventory_location_id,
                           p_lot_number            => p_lot.lot_number,
                           p_serial_number         => NULL,
                           p_object_type           => 'O');
     -- Lot status validation has failed
     IF (l_status_result = 'N')
     THEN
       l_result := INV_VALIDATE.F;
       RETURN l_result;
     END IF;
    END IF;
  END IF;-- End of p_object_type = 'A'

  -- Material status validation for sub, locator and lot has passed
  -- Going ahead to explode intermediate serials within a range and checking
  -- for material status and basic validity of each serial, by calling the
  -- overloaded Validate_serial function.

  -- Clearing the previously cached errored serials and initializing l_errored_serial_count
  -- to 0.
  x_errored_serials.DELETE;
  l_errored_serial_count := 0;

  FOR v_counter IN p_fm_serial.FIRST .. p_fm_serial.LAST
  LOOP

   -- Calling the API to get the range of serials in between a sub-range.
    IF NOT MTL_SERIAL_CHECK.INV_SERIAL_INFO(p_from_serial_number  =>  p_fm_serial(v_counter) ,
             p_to_serial_number    =>  p_to_serial(v_counter) ,
             x_prefix              =>  l_prefix,
             x_quantity            =>  l_quantity,
             x_from_number         =>  l_from_number,
             x_to_number           =>  l_to_number,
             x_errorcode           =>  l_errorcode)
    THEN
      l_result := INV_VALIDATE.F;
      RETURN l_result;
    END IF;

    l_number_part := TO_NUMBER(l_from_number);
    l_counter := 1;
    -- Get the length of the serial number
    l_length := LENGTH(p_fm_serial(v_counter));

    WHILE (l_counter <= l_quantity) LOOP

      -- The padded length will be the length of the serial number minus
      -- the length of the number part
      l_padded_length := l_length - LENGTH(l_number_part);
      l_temp_serial.serial_number := RPAD(NVL(l_prefix,'0'), l_padded_length, '0') ||l_number_part;
      -- Calling the overloaded Validate_serial function.
      l_result := INV_VALIDATE.Validate_serial(
                    p_serial       => l_temp_serial,
                    p_org          => p_org,
                    p_item         => p_item,
                    p_from_sub     => p_from_sub,
                    p_lot          => p_lot,
                    p_loc          => p_loc,
                    p_revision     => p_revision,
                    p_trx_type_id  => p_trx_type_id,
                    p_object_type  => 'S'
                  );
      -- Material status for an intermediate serial has failed, add the serial to the
      -- errored serials list and when the count reaches 10 return from the function.
      IF (l_result = INV_VALIDATE.F) THEN
        l_errored_serial_count := l_errored_serial_count + 1;
        x_errored_serials(l_errored_serial_count) := l_temp_serial.serial_number;
        IF (l_errored_serial_count = 10) THEN
          l_result := INV_VALIDATE.F;
          RETURN l_result;
        END IF;
      END IF;

      l_number_part := l_number_part + 1;
      l_counter :=  l_counter + 1;

    END LOOP;  -- End of WHILE
  END LOOP;  -- End of FOR

  -- If lesser than 10 serials has failed then set l_result to INV_VALIDATE.F
  -- and return.
  IF (l_errored_serial_count <> 0) THEN
    l_result := INV_VALIDATE.F;
    RETURN l_result;
  ELSE
    -- Entire range of serials has passed for material status
    -- set the l_result to INV_VALIDATE.T and return
    l_result := INV_VALIDATE.T;
    RETURN l_result;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
   -- Exception has occured somewhere set the l_result to INV_VALIDATE.F
   -- and return
     l_result := INV_VALIDATE.F;
     RETURN l_result;

END validate_serial_range;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Serial_Number_End ( p_serial IN OUT nocopy serial,
              p_org IN ORG,
              p_item IN ITEM,
              p_from_sub IN sub,
              p_lot in lot,
              p_loc in locator,
              p_revision in VARCHAR2)
RETURN NUMBER
IS

BEGIN

   return check_serial(p_serial,p_org,p_item,p_from_sub,
                p_lot,p_loc, p_revision,
                'INV_END_SERIAL_NUMBER');

END Serial_Number_End;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Serial_Number_Start ( p_serial IN OUT nocopy serial,
                p_org IN ORG,
                p_item IN ITEM,
                p_from_sub IN sub,
                p_lot in lot,
                p_loc in locator,
                p_revision in VARCHAR2)
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

      return check_serial(p_serial,p_org,p_item,p_from_sub,
              p_lot,p_loc, p_revision,
              'INV_START_SERIAL_NUMBER');


END Serial_Number_Start;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION subinventory(p_sub IN OUT NOCOPY sub,
            p_org IN org)
  RETURN NUMBER
  IS
BEGIN
     IF p_sub.secondary_inventory_name IS NULL OR
       p_sub.secondary_inventory_name = fnd_api.g_miss_char
       THEN
   RETURN F;
     END IF;

     SELECT *
       INTO p_sub
       FROM mtl_secondary_inventories
      WHERE secondary_inventory_name =  p_sub.secondary_inventory_name
        AND organization_id = p_org.organization_id
        AND NVL(disable_date,sysdate+1) > sysdate;

     RETURN T;

EXCEPTION

   WHEN no_data_found THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
   THEN
    fnd_message.set_name('INV','INV_INVALID_SUBINV');
    fnd_msg_pub.ADD;
      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
   THEN
    fnd_msg_pub.add_exc_msg(g_pkg_name,'Subinventory');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;

END subinventory;



-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION subinventory(p_sub IN OUT NOCOPY sub,
            p_org IN org,
            p_item IN ITEM)
  RETURN NUMBER
  IS
BEGIN
     IF p_sub.secondary_inventory_name IS NULL OR
       p_sub.secondary_inventory_name = fnd_api.g_miss_char
       THEN
   RETURN F;
     END IF;

     SELECT msi.*
       INTO p_sub
       FROM mtl_secondary_inventories msi,mtl_item_sub_inventories misi
       WHERE msi.secondary_inventory_name =  p_sub.secondary_inventory_name
       AND msi.organization_id = p_org.organization_id
       AND NVL(MSI.DISABLE_DATE,SYSDATE) >= SYSDATE
       AND msi.organization_id = misi.organization_id
       AND msi.secondary_inventorY_name = misi.secondary_inventory
       AND misi.inventory_item_id = p_item.inventory_item_id;

     RETURN T;

EXCEPTION

   WHEN no_data_found THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
   THEN
    fnd_message.set_name('INV','INV_INT_RESSUBEXP');
    fnd_msg_pub.ADD;
      END IF;

      RETURN F;

   WHEN OTHERS THEN

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
   THEN
    fnd_msg_pub.add_exc_msg(g_pkg_name,'Subinventory');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;

END subinventory;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Task ( p_task_id IN NUMBER, p_project_id IN NUMBER )

RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_task_id IS NULL OR
        p_task_id = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    PJM_TASKS_V
    WHERE   PROJECT_ID = p_project_id
      AND   TASK_ID = p_task_id;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_TASK_ERR');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION To_Locator ( p_locator IN OUT nocopy locator,
                      p_org           IN ORG,
                      p_item          IN ITEM,
                      p_to_sub        IN SUB,
                      p_project_id    IN NUMBER,
                      p_task_id       IN NUMBER,
                      p_txn_action_id IN NUMBER)

RETURN NUMBER
IS

BEGIN

   return check_locator(p_locator,
                   p_org, p_item,p_to_sub,
                   p_project_id, p_task_id,
                         p_txn_action_id, f, true);

END To_Locator;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Transaction_Header ( p_transaction_header_id IN NUMBER )
RETURN NUMBER
IS
BEGIN
     RETURN T;
END Transaction_Header;


FUNCTION HR_Location(p_hr_location IN NUMBER)
RETURN NUMBER
IS
 l_dummy     VARCHAR2(20);
BEGIN

    IF p_hr_location IS NULL OR
      p_hr_location = FND_API.G_MISS_NUM
    then
      return T;
    END IF;

    --Bug 6270813, the ship to location LOV on the move orders form fetches locations
    --from both HR_LOCATIONS and HZ_LOCATIONS tables, hence added an exception in the
    --HR_LOCATIONS query and have put another query for checking the location in HZ_LOCATIONS.

    BEGIN

    SELECT 'valid'
      INTO l_dummy
      FROM HR_LOCATIONS
     WHERE LOCATION_ID = p_hr_location;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN

          SELECT 'valid'
            INTO l_dummy
            FROM HZ_LOCATIONS
           WHERE LOCATION_ID = p_hr_location;
     END;

    RETURN T;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_LOCATION');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Uom ( p_uom_code IN VARCHAR2, p_org IN ORG, p_item IN ITEM )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_uom_code IS NULL OR
        p_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN F;
    END IF;

--Bug 2902031
    IF  INV_CONVERT.validate_item_uom( p_uom_code        => p_uom_code
                                      ,p_item_id         => p_item.inventory_item_id
                                      ,p_organization_id => p_org.organization_id)  THEN

        RETURN T;
    END IF;

    /* SELECT  'VALID'
    INTO    l_dummy
    FROM    MTL_ITEM_UOMS_VIEW
    WHERE   ORGANIZATION_ID = p_org.organization_id
      AND   INVENTORY_ITEM_ID = p_item.inventory_item_id
      AND   UOM_CODE = p_uom_code;

    RETURN T;*/

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV-NO ITEM UOM');
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Uom'
            );
        END IF;

        RETURN F;    --Bug2902031
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Uom;

--  END GEN validate

PROCEDURE NUMBER_FROM_SEQUENCE (
        p_sequence   IN     VARCHAR2,
        x_prefix     OUT    NOCOPY VARCHAR2,
        x_number     OUT    NOCOPY NUMBER)
IS
l_ascii_0                  NUMBER;
l_ascii_code_minus_ascii_0 NUMBER;
l_sequence_length          NUMBER;
l_loop_index               NUMBER;
BEGIN
   l_sequence_length := LENGTH(p_sequence);
   l_loop_index      := l_sequence_length;
   l_ascii_0 :=  ASCII('0');
   WHILE l_loop_index >= 1 LOOP
      l_ascii_code_minus_ascii_0 := ASCII(SUBSTR(p_sequence,l_loop_index,1)) - l_ascii_0;
     EXIT WHEN (0 > l_ascii_code_minus_ascii_0 OR
                    l_ascii_code_minus_ascii_0 > 9);
      l_loop_index := l_loop_index - 1;
   END LOOP;
   if(l_loop_index = 0) then
     x_prefix := '';
     x_number := TO_NUMBER(p_sequence);
   elsif(l_loop_index = l_sequence_length) then
     x_prefix := p_sequence;
     x_number := -1;
   else
     x_prefix := SUBSTR(p_sequence,1,l_loop_index);
     x_number := TO_NUMBER(SUBSTR(p_sequence,l_loop_index+1));
   end if;

END NUMBER_FROM_SEQUENCE;


FUNCTION Cost_Group(
   p_cost_group_id IN NUMBER,
   p_org_id IN NUMBER) return NUMBER
IS
   l_cost_group_id NUMBER;
   l_org_id NUMBER;
   l_result NUMBER;
   l_dummy VARCHAR2(10);
BEGIN
   select 'VALID'
   into l_dummy
   from cst_cost_groups
   where cost_group_id = p_cost_group_id;
   return  T;
Exception
   when no_data_found then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_CST_GRP');
            FND_MSG_PUB.Add;
        END IF;
        return F;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,  'Cost Group');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   return F;
END;

FUNCTION LPN( p_lpn_id IN NUMBER) return NUMBER
IS
   l_dummy VARCHAR2(10);
BEGIN
   select 'valid'
   into l_dummy
   from wms_license_plate_numbers
     where lpn_id = p_lpn_id;

RETURN t;

Exception
   when no_data_found then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('INV','INV_INVALID_LPN');
            FND_MSG_PUB.Add;
        END IF;
        return F;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,  'LPN');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   return F;
END;



-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------


/*** Validates a lot in the context of an org and item ***/
FUNCTION Lot_Number(p_lot IN OUT nocopy lot,
          p_org IN ORG,
          p_item IN ITEM)
  RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);

BEGIN
    IF p_lot.lot_number IS NULL OR
        p_lot.lot_number = FND_API.G_MISS_CHAR
    THEN
        RETURN T;
    END IF;

    IF p_item.lot_control_code = 1  THEN
        FND_MESSAGE.SET_NAME('INV','INV_NO_LOT_CONTROL');
        FND_MSG_PUB.Add;
        RETURN F;
    END IF;


    SELECT mln.*
      INTO p_lot
      FROM MTL_LOT_NUMBERS MLN
     WHERE MLN.INVENTORY_ITEM_ID = p_item.inventory_item_id
       AND MLN.ORGANIZATION_ID = p_org.organization_id
      AND MLN.LOT_NUMBER = p_lot.lot_number;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','CAPS_LOT_NUMBER'),FALSE);
            FND_MSG_PUB.Add;

        END IF;
        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Number;
-- ---------------------------------------------------------------------
--INVCONV
-- ---------------------------------------------------------------------
FUNCTION Secondary_Quantity ( p_Secondary_quantity IN NUMBER )
RETURN NUMBER
IS
BEGIN
     IF p_secondary_quantity IS NULL OR
        p_secondary_quantity = FND_API.G_MISS_NUM
     THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_INT_QTYCODE');
            FND_MSG_PUB.Add;
        END IF;
        return F;
     END IF;
     RETURN T;
END Secondary_Quantity;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
--INVCONV

PROCEDURE check_pending_transaction (
  p_transaction_type_id IN  NUMBER,
  p_pending_tran_flag   OUT NOCOPY NUMBER) AS
  /*************************************************************
  Created By     : Nalin Kumar
  Date Created on: 05-05-05
  Purpose        : This procedure will return NULL if there is no
                   pending Transaction for the passed Transaction
                   Type else it will pass '1', which indicates that
                   there are pending transactions. Bug# 4348541
  Change History :
  -------------------------------------------------------------
    Who             When            What
  -------------------------------------------------------------
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_chk_pnd_tran IS
  SELECT 1
  FROM DUAL
  WHERE EXISTS(
    SELECT 1
    FROM mtl_material_transactions_temp mmtt
    WHERE mmtt.transaction_type_id = p_transaction_type_id
    AND NVL(mmtt.transaction_status, 1) IN (1, 3));
BEGIN
  OPEN cur_chk_pnd_tran;
  FETCH cur_chk_pnd_tran INTO p_pending_tran_flag;
  CLOSE cur_chk_pnd_tran;
 EXCEPTION WHEN OTHERS THEN
   NULL;
END check_pending_transaction;

PROCEDURE check_location_required_setup(
  p_transaction_type_id IN NUMBER,
  p_required_flag       OUT NOCOPY VARCHAR2) AS
  /*************************************************************
  Created By     : Nalin Kumar
  Date Created on: 24-May-2005
  Purpose        : This procedure will return 2 if the Location is
                   Required for the given Transaction Type else it
                   will return 1. Based on the returned value from
                   this procedure the "Location' field can be made
                   mandatory in different screens. Bug# 4348541
  Change History :
  -------------------------------------------------------------
    Who             When            What
  -------------------------------------------------------------
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_chk_loc_req IS
  SELECT NVL(location_required_flag, 'N') location_required_flag
  FROM mtl_transaction_types
  WHERE transaction_type_id = NVL(p_transaction_type_id, -1)
    AND user_defined_flag = 'Y';
  rec_chk_loc_req cur_chk_loc_req%ROWTYPE;
BEGIN
  p_required_flag := 'N'; /*Default as not required*/
  OPEN cur_chk_loc_req;
  FETCH cur_chk_loc_req INTO rec_chk_loc_req;
    IF cur_chk_loc_req%FOUND THEN
      p_required_flag := rec_chk_loc_req.location_required_flag;
    END IF;
  CLOSE cur_chk_loc_req;
END check_location_required_setup;
END INV_Validate;

/
