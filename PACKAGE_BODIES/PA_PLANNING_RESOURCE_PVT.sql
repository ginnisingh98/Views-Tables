--------------------------------------------------------
--  DDL for Package Body PA_PLANNING_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLANNING_RESOURCE_PVT" AS
/* $Header: PAPRESVB.pls 120.6.12010000.2 2009/02/09 14:59:41 nisinha ship $*/

/*************************************************************
 * Function    : Check_pl_alias_unique
 * Description : The purpose of this function is to determine
 *               the uniqueness of the resource alias if it is not null.
 *               While inserting when we call this function then if 'N'
 *               is returned then proceed else throw an error.
 *************************************************************/
FUNCTION Check_pl_alias_unique(
          p_resource_list_id        IN   VARCHAR2,
          p_resource_alias          IN   VARCHAR2,
          p_resource_list_member_id IN   VARCHAR2,
          p_object_type             IN   VARCHAR2,
          p_object_id               IN   NUMBER)
  RETURN VARCHAR2
  IS
  l_check_unique_res  varchar2(30) := 'Y';
  BEGIN

     BEGIN
     SELECT 'N'
     INTO l_check_unique_res
     FROM pa_resource_list_members
     WHERE resource_list_id = p_resource_list_id
     AND alias = p_resource_alias
     AND object_type = p_object_type
     AND object_id   = p_object_id
     AND resource_list_member_id <>
      nvl(p_resource_list_member_id,-99);
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_check_unique_res := 'Y';
  END;
  RETURN l_check_unique_res;
  END Check_pl_alias_unique;
/***********************************/
 /************************************************************
 * Function : Default_uom
 * Desc     :
 ************************************************************/
  FUNCTION Default_uom(
          p_resource_class_code     IN   VARCHAR2,
          p_inventory_item_id       IN   NUMBER,
          p_organization_id         IN   NUMBER,
          p_expenditure_type        IN   VARCHAR2)
  RETURN VARCHAR2
  IS
    l_uom                    VARCHAR2(30);
    l_currency               VARCHAR2(1);
    l_organization_id        NUMBER := p_organization_id;
    l_master_organization_id NUMBER;
  BEGIN

  SELECT def.item_master_id
    INTO l_master_organization_id
    FROM pa_resource_classes_b cls,
         pa_plan_res_defaults def
   WHERE cls.resource_class_code = 'MATERIAL_ITEMS'
     AND cls.resource_class_id = def.resource_class_id
     AND def.object_type = 'CLASS';

  IF p_organization_id IS NULL THEN
     l_organization_id := l_master_organization_id;
  ELSE
     l_organization_id := p_organization_id;
  END IF;

       IF p_resource_class_code IN ('PEOPLE','EQUIPMENT') THEN
           l_uom := 'HOURS';
       END IF;

       IF p_resource_class_code = 'MATERIAL_ITEMS' AND l_uom IS NULL AND
          p_inventory_item_id IS NOT NULL THEN
                BEGIN
                SELECT primary_uom_code
                INTO   l_uom
                FROM   mtl_system_items_b items
                WHERE  items.inventory_item_id = p_inventory_item_id
                AND    items.organization_id = l_organization_id
                AND    ROWNUM = 1;

                EXCEPTION WHEN NO_DATA_FOUND THEN
                   l_uom := NULL;
                END;

                IF (l_uom IS NULL) AND
                   (l_organization_id <> l_master_organization_id) THEN
                   SELECT primary_uom_code
                   INTO   l_uom
                   FROM   mtl_system_items_b items
                   WHERE  items.inventory_item_id = p_inventory_item_id
                   AND    items.organization_id = l_master_organization_id;
                END IF;

                IF l_uom IS NOT NULL THEN

                   l_currency := 'N';

                   BEGIN
                   SELECT 'Y'
                   INTO   l_currency
                   FROM   mtl_units_of_measure meas
                   WHERE  meas.uom_code = l_uom
                   AND    meas.uom_class = 'Currency';
                   EXCEPTION WHEN NO_DATA_FOUND THEN
                      l_currency := 'N';

                   END;

                   IF l_currency = 'Y' THEN
                      l_uom := 'DOLLARS';
                   END IF;
               END IF;
       END IF;

       IF p_resource_class_code IN ('MATERIAL_ITEMS', 'FINANCIAL_ELEMENTS')
          AND l_uom IS NULL
          AND p_inventory_item_id IS NULL
          AND p_expenditure_type IS NOT NULL
       THEN
           BEGIN
               SELECT unit_of_measure
               INTO l_uom
               FROM pa_expenditure_types et
               WHERE et.expenditure_type = p_expenditure_type
               AND ROWNUM = 1;
           END;
       END IF;
       IF l_uom IS NULL THEN
          l_uom := 'DOLLARS';
       END IF;
       Return l_uom;
  EXCEPTION
  WHEN OTHERS THEN
       l_uom := Null;
       Return l_uom;
  END Default_uom;

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 *               It first checks for the uniqueness of the
 *               p_resource_alias
 *               It gets the appr resource_class_code of it is Null
 ****************************************************************/
PROCEDURE Create_Planning_Resource
         (p_resource_list_member_id IN   NUMBER   DEFAULT NULL,
         p_resource_list_id       IN   VARCHAR2,
         p_resource_alias         IN   VARCHAR2  DEFAULT NULL,
         p_person_id              IN   NUMBER    DEFAULT NULL,
         p_person_name            IN   VARCHAR2  DEFAULT NULL,
         p_job_id                 IN   NUMBER    DEFAULT NULL,
         p_job_name               IN   VARCHAR2  DEFAULT NULL,
         p_organization_id        IN   NUMBER    DEFAULT NULL,
         p_organization_name      IN   VARCHAR2  DEFAULT NULL,
         p_vendor_id              IN   NUMBER    DEFAULT NULL,
         p_vendor_name            IN   VARCHAR2  DEFAULT NULL,
         p_fin_category_name      IN   VARCHAR2  DEFAULT NULL,
         p_non_labor_resource     IN   VARCHAR2  DEFAULT NULL,
         p_project_role_id        IN   NUMBER    DEFAULT NULL,
         p_project_role_name      IN   VARCHAR2  DEFAULT NULL,
         p_resource_class_id      IN   NUMBER    DEFAULT NULL,
         p_resource_class_code    IN   VARCHAR2  DEFAULT NULL,
         p_res_format_id          IN   NUMBER    ,
         p_spread_curve_id        IN   NUMBER    DEFAULT NULL,
         p_etc_method_code        IN   VARCHAR2  DEFAULT NULL,
         p_mfc_cost_type_id       IN   NUMBER    DEFAULT NULL,
         p_copy_from_rl_flag      IN   VARCHAR2   DEFAULT NULL,
         p_resource_class_flag    IN   VARCHAR2  DEFAULT NULL,
         p_fc_res_type_code       IN   VARCHAR2  DEFAULT NULL,
         p_inventory_item_id      IN   NUMBER    DEFAULT NULL,
         p_inventory_item_name    IN   VARCHAR2  DEFAULT NULL,
         p_item_category_id       IN   NUMBER    DEFAULT NULL,
         p_item_category_name     IN   VARCHAR2  DEFAULT NULL,
         p_migration_code         IN   VARCHAR2  DEFAULT 'N',
         p_attribute_category     IN   VARCHAR2  DEFAULT NULL,
         p_attribute1             IN   VARCHAR2  DEFAULT NULL,
         p_attribute2             IN   VARCHAR2  DEFAULT NULL,
         p_attribute3             IN   VARCHAR2  DEFAULT NULL,
         p_attribute4             IN   VARCHAR2  DEFAULT NULL,
         p_attribute5             IN   VARCHAR2  DEFAULT NULL,
         p_attribute6             IN   VARCHAR2  DEFAULT NULL,
         p_attribute7             IN   VARCHAR2  DEFAULT NULL,
         p_attribute8             IN   VARCHAR2  DEFAULT NULL,
         p_attribute9             IN   VARCHAR2  DEFAULT NULL,
         p_attribute10            IN   VARCHAR2  DEFAULT NULL,
         p_attribute11            IN   VARCHAR2  DEFAULT NULL,
         p_attribute12            IN   VARCHAR2  DEFAULT NULL,
         p_attribute13            IN   VARCHAR2  DEFAULT NULL,
         p_attribute14            IN   VARCHAR2  DEFAULT NULL,
         p_attribute15            IN   VARCHAR2  DEFAULT NULL,
         p_attribute16            IN   VARCHAR2  DEFAULT NULL,
         p_attribute17            IN   VARCHAR2  DEFAULT NULL,
         p_attribute18            IN   VARCHAR2  DEFAULT NULL,
         p_attribute19            IN   VARCHAR2  DEFAULT NULL,
         p_attribute20            IN   VARCHAR2  DEFAULT NULL,
         p_attribute21            IN   VARCHAR2  DEFAULT NULL,
         p_attribute22            IN   VARCHAR2  DEFAULT NULL,
         p_attribute23            IN   VARCHAR2  DEFAULT NULL,
         p_attribute24            IN   VARCHAR2  DEFAULT NULL,
         p_attribute25            IN   VARCHAR2  DEFAULT NULL,
         p_attribute26            IN   VARCHAR2  DEFAULT NULL,
         p_attribute27            IN   VARCHAR2  DEFAULT NULL,
         p_attribute28            IN   VARCHAR2  DEFAULT NULL,
         p_attribute29            IN   VARCHAR2  DEFAULT NULL,
         p_attribute30            IN   VARCHAR2  DEFAULT NULL,
         p_person_type_code       IN   VARCHAR2  DEFAULT NULL,
         p_bom_resource_id        IN   NUMBER    DEFAULT NULL,
         p_bom_resource_name      IN   VARCHAR2  DEFAULT NULL,
         -- Team Role changes
         p_team_role              IN   VARCHAR2  DEFAULT NULL,
         --p_named_role             IN   VARCHAR2  DEFAULT NULL,
         p_incur_by_res_code      IN   VARCHAR2  DEFAULT NULL,
         p_incur_by_res_type      IN   VARCHAR2  DEFAULT NULL,
         --Added this new parameter for project specific res.
         p_project_id             IN   NUMBER    DEFAULT NULL,
         p_init_msg_list          IN   VARCHAR2  DEFAULT FND_API.G_FALSE, -- Added for bug#4350589
         x_resource_list_member_id OUT NOCOPY NUMBER  ,
         x_record_version_number  OUT NOCOPY     NUMBER  ,
         x_return_status          OUT NOCOPY     VARCHAR2,
         x_msg_count              OUT NOCOPY     NUMBER  ,
         x_error_msg_data         OUT NOCOPY     VARCHAR2)
IS
  /********************************
  * Cursor Declaration Section
  ********************************/
   Cursor get_class_details IS
        SELECT resource_class_code
        FROM pa_resource_classes_b
        WHERE resource_class_id = p_resource_class_id;
   Cursor get_fmt_details IS
        SELECT res_type_id,res_type_enabled_flag,
               resource_class_flag
        FROM pa_res_formats_b
        WHERE res_format_id = p_res_format_id;
   Cursor get_res_type(p_res_type_id pa_res_types_b.res_type_id%TYPE )
       IS
      SELECT res_type_code
        FROM pa_res_types_b
        WHERE res_type_id = p_res_type_id;
/**************************************
 * Local Variable Declaration
 *************************************/
l_resource_alias          VARCHAR2(80);
l_res_combo               VARCHAR2(1000);
l_res_class_flag          VARCHAR2(1);
l_incur_by_res_flag       VARCHAR2(30) ;
l_vendor_id               NUMBER       := p_vendor_id;
l_role_id                 NUMBER       := p_project_role_id;
         -- Team Role changes
--Bug 3604528
l_team_role              VARCHAR2(80) := p_team_role;
l_event_type              VARCHAR2(30);
l_error_msg_data          VARCHAR2(30);
l_res_list_member_id      NUMBER       := p_resource_list_member_id;
l_res_class_code          VARCHAR2(30);
l_res_class_id            Number;
l_fmt_details             get_fmt_details%ROWTYPE;
l_res_type                VARCHAR2(30);
l_person_name             per_people_x.full_name%TYPE;
l_resource_id             pa_resources.resource_id%TYPE;
l_unique_res_list         VARCHAR2(30) := null;
--Local vars for Validate_planning_resource
l_resource_code           VARCHAR2(30);
l_resource_name           VARCHAR2(1000);
--For OUT
l_resource_list_member_id NUMBER;
l_person_id               NUMBER;
l_bom_resource_id         NUMBER;
l_job_id                  NUMBER;
l_person_type_code        VARCHAR2(30);
l_non_labor_resource      VARCHAR2(20);
l_inventory_item_id       NUMBER;
l_item_category_id        NUMBER;
l_organization_id         NUMBER;
l_expenditure_type        VARCHAR2(30);
l_expenditure_category    VARCHAR2(30);
l_revenue_category        VARCHAR2(30);
l_resource_class_id       NUMBER;
l_incur_by_role_id        NUMBER;
l_incur_by_res_class_code VARCHAR2(30);
l_return_status           VARCHAR2(30);
l_err_code                NUMBER;
l_err_stage       VARCHAR2(100);
l_err_stack       VARCHAR2(100);
l_msg_data                VARCHAR2(100);
l_msg_count               NUMBER;
l_spread_curve_id        NUMBER;
l_etc_method_code        VARCHAR2(30);
l_mfc_cost_type_id       NUMBER;

-- used for getting inc by name for token for messages
l_inc_person_id          NUMBER := NULL;
l_inc_job_id             NUMBER := NULL;
l_inc_role_id            NUMBER := NULL;
l_inc_person_type        VARCHAR2(30) := NULL;
l_inc_class_code         VARCHAR2(30) := NULL;

l_fin_cat_name           VARCHAR2(80);
l_org_name               VARCHAR2(80);
l_supplier_name          VARCHAR2(80);
l_role_name              VARCHAR2(80);
l_inc_by_name            VARCHAR2(80);

l_res_class_valid        Varchar2(1);

--Project specific changes.
l_object_type            VARCHAR2(30);
l_object_id              NUMBER;
l_wp_eligible_flag       Varchar2(1);
l_num                    Number;
l_done                   Varchar2(1);
l_length                 Number;
l_uom                    Varchar2(30);
l_res_type_code          Varchar2(30);
l_dummy_variable         Varchar2(2000); -- for bug#8237237
BEGIN
-- FND_MSG_PUB.initialize; -- done in public pacakge
-- hr_utility.trace_on(NULL, 'RMDE');
-- hr_utility.trace('**** START ****');
-- hr_utility.trace('**** g_amg_flow IS  ****' || g_amg_flow);
IF g_amg_flow = 'N' OR g_amg_flow IS NULL THEN
-- hr_utility.trace('**** IN IF g_amg_flow IS  ****' || g_amg_flow);
   g_token := NULL;

   SELECT meaning || ' '
   INTO   g_token
   FROM   pa_lookups
   WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
   AND    lookup_code = 'PLANNING_RESOURCE';
END IF;

--hr_utility.trace('g_token is : ' || g_token);
/******************************************************
 * The below IF Condition is used to check for the
 * uniqueness of the p_resource_alias. This is done by call
 * to check_pl_alias_unique. If it returns 'Y' then throw an error
 * and return, else continue with the validation.
 * This If condn is only exec if the resource alias is not null.
 *****************************************************/
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Added for bug#4350589, this procedure is directly getting called from AddSingleResourceVORowImpl
  -- passing p_init_msg_list value explicitly 'T' and message stack will be intialized
  -- for other flows the default value is 'F' and message stack wont be intialized

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- bug#4350589 end

 /*******************************************
 * Assigning the value for l_object_type
 * and l_object_id based on whether the
 * Project ID value is passed or not.
 * *****************************************/
    IF p_project_id IS NOT NULL
    THEN
        l_object_type := 'PROJECT';
        l_object_id   := p_project_id;
    ELSE
        l_object_type := 'RESOURCE_LIST';
        l_object_id   := p_resource_list_id;
    END IF;

   IF p_resource_alias IS NOT NULL THEN
       IF g_amg_flow = 'N' OR g_amg_flow IS NULL THEN
          g_token := g_token || p_resource_alias || ':';
       END IF;

       IF pa_planning_resource_pvt.Check_pl_alias_unique(p_resource_list_id,
       p_resource_alias,l_res_list_member_id,l_object_type,l_object_id) = 'N'
       THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := x_msg_count + 1;
               x_error_msg_data := 'PA_RES_ALIAS_NOT_UNIQUE';
               PA_UTILS.Add_Message ('PA', x_error_msg_data,
                                     'PLAN_RES', g_token);
               Return;
        END IF;
   END IF;
 /******************************************************
 * If the Resource class code is Null then we need
 * to fetch it from the cursor get_class_details
 * If the resource class code is Null and the cursor also
 * doesn't return a value then throw an error  and Return.
 ********************************************************/
   IF p_resource_class_code IS NULL
   THEN
        OPEN get_class_details;
        FETCH get_class_details INTO l_res_class_code;
        IF get_class_details%NOTFOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := x_msg_count + 1;
               x_error_msg_data := 'PA_RES_NO_CLASS_PROVIDED';
               PA_UTILS.Add_Message ('PA', x_error_msg_data,
                                     'PLAN_RES', g_token);
               Return;
        END IF;
     CLOSE get_class_details;
   ELSE
       l_res_class_code := p_resource_class_code;
   END IF;

  IF p_resource_class_id IS NULL
  THEN
      BEGIN
          SELECT resource_class_id
          INTO l_res_class_id
          FROM pa_resource_classes_b
          WHERE resource_class_code = l_res_class_code;
      EXCEPTION
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := x_msg_count + 1;
          Return;
      END;
   ELSE
      l_res_class_id := p_resource_class_id;
   END IF;

   -- If both the class code and ID have been passed in, validate
   -- that they are a valid pair - this is for AMG flows mostly
   -- as the page should always pass in values which are in sync.
   -- Bug 4507065.
   IF p_resource_class_id IS NOT NULL AND
      p_resource_class_code IS NOT NULL THEN
      BEGIN
          SELECT 'Y'
          INTO l_res_class_valid
          FROM pa_resource_classes_b
          WHERE resource_class_code = p_resource_class_code
          AND resource_class_id = p_resource_class_id;

      EXCEPTION
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := x_msg_count + 1;
          x_error_msg_data := 'PA_RES_CLASS_INVALID';
          PA_UTILS.Add_Message ('PA', x_error_msg_data,
                                'PLAN_RES', g_token);
          Return;
      END;

   END IF;

/*********************************************************
 * This If condition checks if the resource format ID is
 * not null. IF NOT NULL then it needs to get the resource format details
 * like res_type_id, res_type_enabled_flag and resource_class_flag.
 * If the cursor does not return anything then we need to throw an error
 * and Return.
 *********************************************************/
   IF p_res_format_id IS NOT NULL THEN
        OPEN get_fmt_details;
          FETCH get_fmt_details into l_fmt_details;
          IF get_fmt_details%NOTFOUND THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_error_msg_data := 'PA_PLN_RL_FORMAT_BAD_FMT_ID';
                PA_UTILS.Add_Message ('PA', x_error_msg_data,
                                     'PLAN_RES', g_token);
                x_record_version_number := null;
                x_msg_count := x_msg_count + 1;
                Return;
           END IF;
         CLOSE get_fmt_details;
   END IF;
/**********************************************************
 * This If condition checks if Resource is a part of the format.
 * It makes use of the Values returned by the Prev cursor. ie
 * This check is done only if the l_fmt_details.res_type_enabled_flag
 * = 'Y'. If the cursor doesn't return a value then return.
 *******************************************************/
   IF l_fmt_details.res_type_enabled_flag = 'Y' THEN
         OPEN get_res_type(l_fmt_details.res_type_id);
         FETCH get_res_type INTO l_res_type;
         IF get_res_type%NOTFOUND THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_msg_count := x_msg_count + 1;
              CLOSE get_res_type;
              Return;
         END IF;
         CLOSE get_res_type;
     ELSE
           l_res_type := null;
     END IF;
/***************************************************************
 * Before Call to Validate_Resource_Planning Procedure,
 * The values for some of the variables being passed need to be set.
 * This condn needs to be executed only of l_res_type is not NULL.
 * A value needs to be set for the l_resource_code and
 * l_resource_name variables, based on the value of l_res_type.
 **********************************************************/

  IF l_res_type IS NOT NULL THEN
         IF l_res_type = 'NAMED_PERSON' THEN
               l_resource_code := p_person_id;
               l_resource_name := p_person_name;
         ELSIF l_res_type IN ('BOM_LABOR','BOM_EQUIPMENT') THEN
               l_resource_code := p_bom_resource_id;
               l_resource_name := p_bom_resource_name;
         ELSIF l_res_type = 'NAMED_ROLE' THEN
               -- Team Role changes
               l_resource_code := p_team_role;
               l_resource_name := p_team_role;
         ELSIF l_res_type = 'JOB' THEN
               l_resource_code := p_job_id;
               l_resource_name := p_job_name;
         ELSIF l_res_type = 'PERSON_TYPE' THEN
               l_resource_code := p_person_type_code;
               l_resource_name := p_person_type_code;
         ELSIF l_res_type = 'NON_LABOR_RESOURCE' THEN
               l_resource_code := p_non_labor_resource;
               l_resource_name := p_non_labor_resource;
         ELSIF l_res_type = 'INVENTORY_ITEM' THEN
               l_resource_code := p_inventory_item_id;
               l_resource_name := p_inventory_item_name;
         ELSIF l_res_type = 'ITEM_CATEGORY' THEN
               l_resource_code := p_item_category_id;
               l_resource_name := p_item_category_name;
         ELSIF l_res_type = 'RESOURCE_CLASS' THEN
               l_resource_code := p_resource_class_code;
               l_resource_name := p_resource_class_code;
         END IF;

      IF p_resource_alias IS NULL AND (g_amg_flow = 'N' OR g_amg_flow IS NULL)
      THEN
--hr_utility.trace('before g_token is : ' || g_token);
         g_token := g_token || pa_planning_resource_utils.ret_Resource_Name(
                       p_Res_Type_Code      => l_res_type,
                       P_Person_Id          => p_person_id,
                       P_Bom_Resource_Id    => p_bom_resource_id,
                       P_Job_Id             => p_job_id,
                       P_Person_Type_Code   => l_resource_code,
                       P_Non_Labor_Resource => l_resource_code,
                       P_Inventory_Item_Id  => p_inventory_item_id,
                       P_Resource_Class_Id  => l_res_class_id,
                       P_Item_Category_Id   => p_item_category_id,
                       p_res_assignment_id  => NULL);
--hr_utility.trace('after g_token is : ' || g_token);
      END IF;
   END IF;

   IF p_resource_alias IS NULL AND (g_amg_flow = 'N' OR g_amg_flow IS NULL)
   THEN
      IF p_incur_by_res_type IS NOT NULL THEN
         IF p_incur_by_res_type = 'NAMED_PERSON' THEN
            l_inc_person_id := p_incur_by_res_code;
         ELSIF p_incur_by_res_type = 'JOB' THEN
            l_inc_job_id := p_incur_by_res_code;
         ELSIF p_incur_by_res_type = 'ROLE' THEN
            l_inc_role_id := p_incur_by_res_code;
         ELSIF p_incur_by_res_type = 'PERSON_TYPE' THEN
            l_inc_person_type := p_incur_by_res_code;
         ELSIF p_incur_by_res_type = 'RESOURCE_CLASS' THEN
            l_inc_class_code := p_incur_by_res_code;
         END IF;
      END IF;
--hr_utility.trace('before all others  g_token is : ' || g_token);
      l_fin_cat_name := pa_planning_resource_utils.Ret_Fin_Category_Name(
                    P_FC_Res_Type_Code      => p_fc_res_type_code,
                    P_Expenditure_Type      => p_fin_category_name,
                    P_Expenditure_Category  => p_fin_category_name,
                    P_Event_Type            => p_fin_category_name,
                    P_Revenue_Category_Code => p_fin_category_name);
      l_org_name := nvl(p_organization_name,
                     pa_planning_resource_utils.ret_Organization_Name(
                        P_Organization_Id => p_organization_id));
      l_supplier_name := nvl(p_vendor_name,
                     pa_planning_resource_utils.ret_supplier_Name(
                        P_supplier_id => p_vendor_id));
      l_role_name := p_team_role;
      l_inc_by_name := pa_planning_resource_utils.Ret_Incur_By_Res_Name(
                        P_Person_Id             => l_inc_person_id,
                        P_Job_Id                => l_inc_job_id,
                        P_Incur_By_Role_Id      => l_inc_role_id,
                        P_Person_Type_Code      => l_inc_person_type,
                        P_Inc_By_Res_Class_Code => l_inc_class_code);
      SELECT g_token ||
             decode(l_fin_cat_name, NULL, NULL, '-' || l_fin_cat_name) ||
             decode(l_org_name, NULL, NULL, '-' || l_org_name) ||
             decode(l_supplier_name, NULL, NULL, '-' || l_supplier_name) ||
             decode(l_role_name, NULL, NULL, '-' || l_role_name) ||
             decode(l_inc_by_name, NULL, NULL, '-' || l_inc_by_name)
      INTO   g_token
      FROM   dual;
      IF l_res_type IS NULL THEN
         g_token := replace(g_token, ' -', ' ');
      END IF;
      g_token := g_token || ':';
--hr_utility.trace('after all others  g_token is : ' || g_token);
   END IF;
/**************************************************************
 * Call to the Package Validate_Planning_Resource
 * which will Validate the planning resource and the
 * resource elements. If this package returns an error, then
 * we need to throw an error and return, else proceed.
 **********************************************************/
  pa_planning_resource_utils.Validate_Planning_Resource
          (p_task_name              =>  null,
          p_task_number             =>  null,
          p_planning_resource_alias =>  null,
          p_resource_list_member_id =>  null,
          p_resource_list_id        =>  p_resource_list_id,
          p_res_format_id           =>  p_res_format_id,
          p_resource_class_code     =>  l_res_class_code,
          p_res_type_code           =>  l_res_type,
          p_resource_code           =>  l_resource_code,
          p_resource_name           =>  l_resource_name,
          p_project_role_id         =>  p_project_role_id,
          p_project_role_name       =>  p_project_role_name,
          -- Team Role changes
          p_team_role               =>  p_team_role,
          p_organization_id         =>  p_organization_id,
          p_organization_name       =>  p_organization_name,
          p_fc_res_type_code        =>  p_fc_res_type_code,
          p_fin_category_name       =>  p_fin_category_name,
          p_supplier_id             =>  p_vendor_id,
          p_supplier_name           =>  p_vendor_name,
          p_incur_by_resource_code  =>  p_incur_by_res_code,
          p_incur_by_resource_type  =>  p_incur_by_res_type,
          x_resource_list_member_id =>  l_resource_list_member_id,
          x_person_id               =>  l_person_id,
          x_bom_resource_id         =>  l_bom_resource_id,
          x_job_id                  =>  l_job_id,
          x_person_type_code        =>  l_person_type_code,
          x_non_labor_resource      =>  l_non_labor_resource,
          x_inventory_item_id       =>  l_inventory_item_id,
          x_item_category_id        =>  l_item_category_id,
          x_project_role_id         =>  l_role_id,
          -- Team Role changes
          x_team_role               =>  l_team_role,
          x_organization_id         =>  l_organization_id,
          x_expenditure_type        =>  l_expenditure_type,
          x_expenditure_category    =>  l_expenditure_category,
          x_event_type              =>  l_event_type,
          x_revenue_category_code   =>  l_revenue_category,
          x_supplier_id             =>  l_vendor_id,
          x_resource_class_id       =>  l_resource_class_id,
          x_resource_class_flag     =>  l_res_class_flag,
          x_incur_by_role_id        =>  l_incur_by_role_id,
          x_incur_by_res_class_code =>  l_incur_by_res_class_code,
          x_incur_by_res_flag       =>  l_incur_by_res_flag,
          x_return_status           =>  x_return_status,
          x_msg_data                =>  x_error_msg_data,
          x_msg_count               =>  x_msg_count);
-- dbms_output.put_line('- After Validate_plan_res l_vendor_id IS : '|| l_vendor_id);


/********************************************************
 * If the Validate package errors out then throw an error and
 * Return.
 ********************************************************/
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
    END IF;

/******************************************************
 * If the l_res_type returned = 'NAMED_PERSON' then
 * first we need to get the value of person_name into
 * l_person_name based on l_person_id.
 * This is obtained from the per_people_x view
 * Then Insert into pa_resources
 * followed by insert into pa_resources_txn_attributes
 ***************************************************/

 IF l_res_type = 'NAMED_PERSON' THEN
       BEGIN
          SELECT full_name
          INTO   l_person_name
          FROM   per_people_x
          WHERE person_id = l_person_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_person_name := null;
       END;
/***********************************************
 * First check if the resource already exists.
 * *********************************************/
    PA_GET_RESOURCE.Get_Resource
                 (p_resource_name           => l_person_name,
                  p_resource_type_Code      => 'EMPLOYEE',
                  p_person_id               => l_person_id,
                  p_job_id                  => NULL,
                  p_proj_organization_id    => NULL,
                  p_vendor_id               => NULL,
                  p_expenditure_type        => NULL,
                  p_event_type              => NULL,
                  p_expenditure_category    => NULL,
                  p_revenue_category_code   => NULL,
                  p_non_labor_resource      => NULL,
                  p_system_linkage          => NULL,
                  p_project_role_id         => NULL,
                  p_resource_id             => l_resource_id,
                  p_err_code                => l_err_code,
                  p_err_stage               => l_err_stage,
                  p_err_stack               => l_err_stack );

      IF l_err_code <> 0 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         x_error_msg_data  := l_err_stage;
         pa_utils.add_message('PA', l_err_stage);
         RETURN;
      END IF;

   IF l_resource_id IS NULL THEN

      /***********************************************
       * Insert into PA_RESOURCES and PA_RESOURCE_TXN_ATTRIBUTES
       * Table. This is done by a call to
       * pa_create_resource.Create_Resource procedure.
       ************************************************/
         pa_create_resource.Create_Resource
                (p_resource_name            => l_person_name,
                 p_resource_type_Code       => 'EMPLOYEE',
                 p_description              => l_person_name,
                 p_unit_of_measure          => NULL,
                 p_rollup_quantity_flag     => NULL,
                 p_track_as_labor_flag      => NULL,
                 p_start_date               => SYSDATE,
                 p_end_date                 => NULL,
                 p_person_id                => l_person_id,
                 p_job_id                   => NULL,
                 p_proj_organization_id     => NULL,
                 p_vendor_id                => NULL,
                 p_expenditure_type         => NULL,
                 p_event_type               => NULL,
                 p_expenditure_category     => NULL,
                 p_revenue_category_code    => NULL,
                 p_non_labor_resource       => NULL,
                 p_system_linkage           => NULL,
                 p_project_role_id          => NULL,
                 p_resource_id              => l_resource_id,
                 p_err_code                 => l_err_code,
                 p_err_stage                => l_err_stage,
                 p_err_stack                => l_err_stack);

      IF l_err_code <> 0 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         x_error_msg_data  := l_err_stage;
         pa_utils.add_message('PA', l_err_stage);
         RETURN;
      END IF;
   END IF;
 END IF;

/***********************************************************
 * Do a Check to determine the uniqueness of the resource
 *  in the Resource list. Only if it is Unique we need
 * to to the Insert Into PA_RESOURCE_LIST_MEMBERS.
 * If it is not Unique then we should display an error
 * saying  'Planning resource already exists in this
 * Planning resource list'
 * If its = 'Y' dont insert. If it is = 'N' then insert.
 ********************************************************/
  /*******************************************************
  * Bug         : 3486256
  * Description : This fix has been done to fix the Duplicates issue.
  *               Earlier the NVL for incurred_by_res_flag
  *               used to check for 'B' but while inserting if
  *               the value was Null we were inserting 'N'
  *               Therefore it used to never find the dup record.
  *               We have now added NVL 'N' clause to help solve
  *               the issue.
  **********************************************************/
  BEGIN
     Select 'Y'
     Into l_unique_res_list
     From pa_resource_list_members
     Where resource_list_id = p_resource_list_id
     And res_format_id = p_res_format_id
      --Added the below 2 lines to check for the uniqueness
      -- on a list/proj combination.
      -- Removed NVL for performance tuning
     And object_type = nvl(l_object_type,'DUMMY')
     And object_id = nvl(l_object_id,-99)
     -- Added resource class ID for performance
     and resource_class_Id = l_res_class_id
     And nvl(person_id, -99) = nvl(l_person_id, -99)
     And nvl(organization_id, -99) = nvl(l_organization_id, -99)
     And nvl(job_id, -99) = nvl(l_job_id, -99)
     And nvl(vendor_id, -99) = nvl(l_vendor_id, -99)
     -- Team Role Changes.
     --And nvl(PROJECT_ROLE_ID, -99) = nvl(l_role_id, -99)
     And nvl(inventory_item_id, -99) = nvl(l_inventory_item_id, -99)
     And nvl(item_category_id, -99) = nvl(l_item_category_id, -99)
     And nvl(bom_resource_id, -99) = nvl(l_bom_resource_id, -99)
     And nvl(person_type_code, 'DUMMY') = nvl(l_person_type_code, 'DUMMY')
     -- Team Role changes
     And nvl(team_role, 'DUMMY') = nvl(l_team_role, 'DUMMY')
     And nvl(incurred_by_res_flag, 'N') = nvl(l_incur_by_res_flag, 'N')
     And nvl(incur_by_res_class_code, 'DUMMY') =
                  nvl(l_incur_by_res_class_code,'DUMMY')
     And nvl(incur_by_role_id, -99) = nvl(l_incur_by_role_id, -99)
     And nvl(expenditure_type,'DUMMY') = nvl(l_expenditure_type, 'DUMMY')
     And nvl(event_type, 'DUMMY') = nvl(l_event_type, 'DUMMY')
     And nvl(non_labor_resource, 'DUMMY') =
                          nvl(l_non_labor_resource, 'DUMMY')
     And nvl(expenditure_category, 'DUMMY')
                         = nvl(l_expenditure_category,'DUMMY')
     And nvl(revenue_category, 'DUMMY') = nvl(l_revenue_category, 'DUMMY');
EXCEPTION
WHEN NO_DATA_FOUND THEN
     l_unique_res_list := 'N';
WHEN OTHERS THEN
     l_unique_res_list := 'Y';
END;

IF l_unique_res_list = 'Y' THEN
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_msg_data := 'PA_NOT_UNIQUE_RES_LIST_MEMBER';
     -- FND_MESSAGE.SET_TOKEN('PLAN_RES', g_token);
     PA_UTILS.Add_Message ('PA', x_error_msg_data, 'PLAN_RES', g_token);
     -- PA_UTILS.Add_Message ('PA', x_error_msg_data);
     Return;
END IF;

/***************************************************
 * Derive the value which will be passed to
 * WP_ELIGIBLE_FLAG column, while calling the
 * Insert_row procedure.
 * This value is got by call to Validate_Fin_Cat_For_WP
 * Function, which takes in the p_fc_res_type_code
 * and returns a 'Y' or 'N'.
 * ************************************************/
  l_wp_eligible_flag :=
    PA_TASK_ASSIGNMENT_UTILS.Validate_Fin_Cat_For_WP(p_fc_res_type_code);

  l_uom := Default_uom(
          p_resource_class_code     => l_res_class_code,
          p_inventory_item_id       => l_inventory_item_id,
          p_organization_id         => l_organization_id,
          p_expenditure_type        => l_expenditure_type);

/*************************************************
 * Insert Into Pa_resource_list_members
 ************************************************/
   IF l_res_list_member_id IS NULL THEN
      SELECT pa_resource_list_members_s.NEXTVAL
      INTO l_res_list_member_id
      FROM dual;
   END IF;

   If l_inventory_item_id is Not Null Then

       l_dummy_variable:= Pa_Uom.Get_Uom(P_user_id  => Fnd_Global.User_Id,
                                         P_uom_code => l_uom);

   End If;

    /********************************************
    * Call to Pa_Planning_Resource_pkg.insert_row
    * Procedure, which will insert into the
    * pa_resource_list_members table.
    ********************************************/

    pa_res_list_members_pkg.insert_row
        (p_resource_list_member_id =>  l_res_list_member_id,
         p_resource_list_id        =>  p_resource_list_id,
         p_resource_id             =>  l_resource_id,
         p_resource_alias          =>  p_resource_alias,
         p_person_id               =>  l_person_id,
         p_job_id                  =>  l_job_id               ,
         p_organization_id         =>  l_organization_id      ,
         p_vendor_id               =>  l_vendor_id            ,
         p_expenditure_type        =>  l_expenditure_type     ,
         p_event_type              =>  l_event_type           ,
         p_non_labor_resource      =>  l_non_labor_resource   ,
         p_expenditure_category    =>  l_expenditure_category ,
         p_revenue_category        =>  l_revenue_category     ,
         p_role_id                 =>  l_role_id              ,
         p_resource_class_id       =>  l_res_class_id    ,
         p_res_class_code          =>  l_res_class_code       ,
         p_res_format_id           =>  p_res_format_id        ,
         p_spread_curve_id         =>  p_spread_curve_id      ,
         p_etc_method_code         =>  p_etc_method_code      ,
         p_mfc_cost_type_id        =>  p_mfc_cost_type_id     ,
         p_res_class_flag          =>  l_res_class_flag       ,
         p_fc_res_type_code        =>  p_fc_res_type_code     ,
         p_inventory_item_id       =>  l_inventory_item_id    ,
         p_item_category_id        =>  l_item_category_id     ,
         p_attribute_category      =>  p_attribute_category   ,
         p_attribute1              =>  p_attribute1           ,
         p_attribute2              =>  p_attribute2           ,
         p_attribute3              =>  p_attribute3           ,
         p_attribute4              =>  p_attribute4           ,
         p_attribute5              =>  p_attribute5           ,
         p_attribute6              =>  p_attribute6           ,
         p_attribute7              =>  p_attribute7           ,
         p_attribute8              =>  p_attribute8           ,
         p_attribute9              =>  p_attribute9           ,
         p_attribute10             =>  p_attribute10          ,
         p_attribute11             =>  p_attribute11          ,
         p_attribute12             =>  p_attribute12          ,
         p_attribute13             =>  p_attribute13          ,
         p_attribute14             =>  p_attribute14          ,
         p_attribute15             =>  p_attribute15          ,
         p_attribute16             =>  p_attribute16          ,
         p_attribute17             =>  p_attribute17          ,
         p_attribute18             =>  p_attribute18          ,
         p_attribute19             =>  p_attribute19          ,
         p_attribute20             =>  p_attribute20          ,
         p_attribute21             =>  p_attribute21          ,
         p_attribute22             =>  p_attribute22          ,
         p_attribute23             =>  p_attribute23          ,
         p_attribute24             =>  p_attribute24          ,
         p_attribute25             =>  p_attribute25          ,
         p_attribute26             =>  p_attribute26          ,
         p_attribute27             =>  p_attribute27          ,
         p_attribute28             =>  p_attribute28          ,
         p_attribute29             =>  p_attribute29          ,
         p_attribute30             =>  p_attribute30          ,
         p_person_type_code        =>  l_person_type_code,
         p_bom_resource_id         =>  l_bom_resource_id,
         p_team_role               =>  l_team_role,
         p_incur_by_res_class_code =>  l_incur_by_res_class_code,
         p_incur_by_role_id        =>  l_incur_by_role_id,
         p_incur_by_res_flag       =>  l_incur_by_res_flag,
         p_object_type             =>  l_object_type,
         p_object_id               =>  l_object_id,
         p_wp_eligible_flag        =>  l_wp_eligible_flag,
         p_unit_of_measure         =>  l_uom,
         x_msg_count               =>  x_msg_count,
         x_return_status           =>  x_return_status ,
         x_error_msg_data          =>  x_error_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count :=  x_msg_count + 1;
           RETURN;
      END IF;

   /**************************************************
    * Get the default values for the spread_curve_id,
    * etc_method_code and mfc_cost_type_id, if no values
    * are passed.
    *************************************************/
   /*************************************************
    * The below select would get the default values for
    * spread curve id, etc method code and mfc cost type id
    **************************************************/
    BEGIN
       SELECT spread_curve_id,
              etc_method_code,
              mfc_cost_type_id
       INTO   l_spread_curve_id,
              l_etc_method_code,
              l_mfc_cost_type_id
       FROM   Pa_Plan_Res_Defaults
       WHERE  resource_class_id = l_res_class_id
       AND    object_type = 'CLASS';
    EXCEPTION
    WHEN OTHERS THEN
        l_spread_curve_id := NULL;
        l_etc_method_code := NULL;
        l_mfc_cost_type_id := NULL;
    END;
/******************************************************
 * If the values for spread curve id, etc method code
 * and mfc cost type id are Not null then retain the same values
 * else use the derived values(from above).
 *****************************************************/
   UPDATE  pa_resource_list_members
   SET  spread_curve_id = DECODE(spread_curve_id,NULL,
                         l_spread_curve_id, spread_curve_id),
        etc_method_code = DECODE(etc_method_code,NULL,
                         l_etc_method_code, etc_method_code)
   WHERE  resource_list_member_id = l_res_list_member_id;

   BEGIN
      SELECT res.res_type_code
      INTO l_res_type_code
      from pa_res_formats_b fmt,pa_res_types_b res
      where fmt.res_type_id = res.res_type_id
      and fmt.res_format_id = p_res_format_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_res_type_code := NULL;
   END;

   IF l_res_type_code IN ('BOM_EQUIPMENT','BOM_LABOR','INVENTORY_ITEM')
   THEN
        UPDATE  pa_resource_list_members
        SET  mfc_cost_type_id = DECODE(mfc_cost_type_id,NULL,
            l_mfc_cost_type_id, mfc_cost_type_id)
        WHERE  resource_list_member_id = l_res_list_member_id;
   ELSE
         UPDATE  pa_resource_list_members
         SET  mfc_cost_type_id = NULL
         WHERE  resource_list_member_id = l_res_list_member_id;
   END IF;

/**************************************************
 * If the p_resource_alias is Null then
 * we need to derive it by call to procedure
 * PA_PLANNING_RESOURCE_DEFAULTS. Get_Plan_Res_Combination
 * and then we need to update the table pa_resource_list_members
 * with the derived value.
 ***************************************************/
 IF p_resource_alias IS NULL
 THEN
/***************************************************
 * Get_Plan_Res_Combination
 *************************************************/
     PA_PLANNING_RESOURCE_UTILS. Get_Plan_Res_Combination(
        P_Resource_List_Member_Id  => l_res_list_member_id,
        X_resource_alias           => l_resource_alias,
        X_Plan_Res_Combination     => l_res_combo,
        X_Return_Status            => l_return_status,
        X_Msg_Count                => l_msg_count,
        X_Msg_Data                 => l_error_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           -- PA_UTILS.Add_Message ('PA', l_error_msg_data);
           Return;
    END IF;
   /*****************************************************
    * Bug - 3509278
    * Desc - Generating Unique Alias.
    ****************************************************/
   l_length := length(l_resource_alias);
   IF l_length > 77 THEN
      l_length := 77;
   END IF;

   IF pa_planning_resource_pvt.Check_pl_alias_unique(p_resource_list_id,
    l_resource_alias,l_res_list_member_id,l_object_type,l_object_id) = 'N'
   THEN
      l_num := 1;
      l_done := 'N';
      LOOP
        EXIT when l_done = 'Y';
        l_resource_alias :=
        substr(l_resource_alias, 1, l_length)|| l_num;
        IF pa_planning_resource_pvt.Check_pl_alias_unique(p_resource_list_id,
        l_resource_alias,l_res_list_member_id,l_object_type,l_object_id)= 'Y'
        THEN
              l_done := 'Y';
        END IF;
        l_num := l_num + 1;
      END LOOP;
        -- x_return_status := FND_API.G_RET_STS_ERROR;
        -- x_msg_count := x_msg_count + 1;
        -- x_error_msg_data := 'PA_RES_ALIAS_NOT_UNIQUE';
        -- PA_UTILS.Add_Message ('PA', x_error_msg_data);
        -- Return;
   END IF;

   BEGIN
      UPDATE pa_resource_list_members
      SET alias = l_resource_alias
      WHERE resource_list_member_id = l_res_list_member_id;
   EXCEPTION
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := x_msg_count + 1;
         Return;
   END;

 END IF;
--Increment the x_record_version_number after Insert.
 x_resource_list_member_id := l_res_list_member_id;
 x_record_version_number := 1;
/**************************************************/
END Create_Planning_Resource;
/*************************************/

/***************************************************
 * Procedure : Update_Planning_Resource
 * Description : The purpose of this procedure is to
 *               Validate and update attributes on an existing
 *               planning resource for a resource list.
 *               It first checks for the Uniqueness of the
 *               resource list. If it is Unique then it updates
 *               the table PA_RESOURCE_LIST_MEMBERS
 *               with the values passed.
 ************************************/
PROCEDURE Update_Planning_Resource
         (p_resource_list_id       IN   NUMBER,
         p_resource_list_member_id IN NUMBER,
         p_enabled_flag           IN   VARCHAR2,
         p_resource_alias         IN   VARCHAR2  ,
         p_spread_curve_id        IN   NUMBER    DEFAULT NULL,
         p_etc_method_code        IN   VARCHAR2  DEFAULT NULL,
         p_mfc_cost_type_id       IN   NUMBER    DEFAULT NULL,
         p_attribute_category     IN   VARCHAR2  DEFAULT NULL,
         p_attribute1             IN   VARCHAR2  DEFAULT NULL,
         p_attribute2             IN   VARCHAR2  DEFAULT NULL,
         p_attribute3             IN   VARCHAR2  DEFAULT NULL,
         p_attribute4             IN   VARCHAR2  DEFAULT NULL,
         p_attribute5             IN   VARCHAR2  DEFAULT NULL,
         p_attribute6             IN   VARCHAR2  DEFAULT NULL,
         p_attribute7             IN   VARCHAR2  DEFAULT NULL,
         p_attribute8             IN   VARCHAR2  DEFAULT NULL,
         p_attribute9             IN   VARCHAR2  DEFAULT NULL,
         p_attribute10            IN   VARCHAR2  DEFAULT NULL,
         p_attribute11            IN   VARCHAR2  DEFAULT NULL,
         p_attribute12            IN   VARCHAR2  DEFAULT NULL,
         p_attribute13            IN   VARCHAR2  DEFAULT NULL,
         p_attribute14            IN   VARCHAR2  DEFAULT NULL,
         p_attribute15            IN   VARCHAR2  DEFAULT NULL,
         p_attribute16            IN   VARCHAR2  DEFAULT NULL,
         p_attribute17            IN   VARCHAR2  DEFAULT NULL,
         p_attribute18            IN   VARCHAR2  DEFAULT NULL,
         p_attribute19            IN   VARCHAR2  DEFAULT NULL,
         p_attribute20            IN   VARCHAR2  DEFAULT NULL,
         p_attribute21            IN   VARCHAR2  DEFAULT NULL,
         p_attribute22            IN   VARCHAR2  DEFAULT NULL,
         p_attribute23            IN   VARCHAR2  DEFAULT NULL,
         p_attribute24            IN   VARCHAR2  DEFAULT NULL,
         p_attribute25            IN   VARCHAR2  DEFAULT NULL,
         p_attribute26            IN   VARCHAR2  DEFAULT NULL,
         p_attribute27            IN   VARCHAR2  DEFAULT NULL,
         p_attribute28            IN   VARCHAR2  DEFAULT NULL,
         p_attribute29            IN   VARCHAR2  DEFAULT NULL,
         p_attribute30            IN   VARCHAR2  DEFAULT NULL,
         p_record_version_number  IN   NUMBER,
         x_record_version_number  OUT NOCOPY  NUMBER  ,
         x_return_status          OUT NOCOPY     VARCHAR2  ,
         x_msg_count              OUT NOCOPY     NUMBER    ,
         x_error_msg_data         OUT NOCOPY     VARCHAR2  )
IS

l_resource_alias VARCHAR2(80);
l_res_combo      VARCHAR2(1000);
l_object_id      NUMBER;
l_object_type    VARCHAR2(30);
l_num            NUMBER;
l_done           VARCHAR2(1);
l_length         NUMBER;
l_allowed        VARCHAR2(1) := 'Y';

BEGIN
IF g_amg_flow = 'N' OR g_amg_flow IS NULL THEN
   SELECT meaning || ' '
   INTO   g_token
   FROM   pa_lookups
   WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
   AND    lookup_code = 'PLANNING_RESOURCE';

   g_token := g_token || nvl(p_resource_alias,
               PA_PLANNING_RESOURCE_UTILS.Get_Plan_Res_Combination(
                  P_Resource_List_Member_Id => P_Resource_List_Member_Id));
END IF;

FND_MSG_PUB.initialize;
x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
     SELECT object_type,object_id
     INTO   l_object_type,l_object_id
     FROM   pa_resource_list_members
     WHERE  resource_list_member_id = p_resource_list_member_id;
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count :=  x_msg_count + 1;
      RETURN;
  END;

 /***************************************************
 * Check if Resource List member is Unique. Done by
 * Call to pa_planning_resource_pvt.Check_pl_alias_unique
 * If it returns a value that means it is not unique
 * Display an error and return.
 **************************************************/

 -- Bug 3719859 - when a user has nulled out the alias, we need to
 -- rederive it - so treat G_MISS_CHAR as NULL.
 --
----hr_utility.trace_on(NULL, 'RMALIAS');
----hr_utility.trace('start - before alias check');
----hr_utility.trace('p_resource_alias is : ' || p_resource_alias);
 --IF (p_resource_alias IS NULL OR p_resource_alias = FND_API.G_MISS_CHAR) THEN

   IF p_resource_alias IS NULL THEN
----hr_utility.trace('p_resource_alias is NULL - derive');
    -- Derive the default alias and use that.
    /**************************************************
    * Derive the default Alias and Use that.
    ****************************************************/
     Pa_Planning_Resource_Utils.Get_Plan_Res_Combination(
        P_Resource_List_Member_Id  => p_resource_list_member_id,
        X_resource_alias           => l_resource_alias,
        X_Plan_Res_Combination     => l_res_combo,
        X_Return_Status            => x_return_status,
        X_Msg_Count                => x_msg_count,
        X_Msg_Data                 => x_error_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           -- PA_UTILS.Add_Message ('PA', x_error_msg_data);
           Return;
    END IF;

    l_length := length(l_resource_alias);
    IF l_length > 77 THEN
       l_length := 77;
    END IF;
    IF pa_planning_resource_pvt.Check_pl_alias_unique(p_resource_list_id,
       l_resource_alias,p_resource_list_member_id,
       l_object_type,l_object_id) = 'N' THEN
       l_num := 1;
       l_done := 'N';
       LOOP
       EXIT when l_done = 'Y';
          l_resource_alias :=
          substr(l_resource_alias, 1, l_length)|| l_num;
          IF pa_planning_resource_pvt.Check_pl_alias_unique(
             p_resource_list_id, l_resource_alias,
             p_resource_list_member_id,l_object_type,l_object_id)= 'Y' THEN
                l_done := 'Y';
          END IF;
          l_num := l_num + 1;
       END LOOP;
    END IF;

    ----hr_utility.trace('after derivation l_resource_alias is : ' || l_resource_alias);

 ELSE
    l_resource_alias := p_resource_alias;
    ----hr_utility.trace('l_resource_alias is : ' || l_resource_alias);
    IF pa_planning_resource_pvt.Check_pl_alias_unique(
              p_resource_list_id        => p_resource_list_id,
              p_resource_alias          => l_resource_alias,
              p_resource_list_member_id => p_resource_list_member_id,
              p_object_type             => l_object_type,
              p_object_id               => l_object_id) = 'N'
    THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_data := 'PA_RES_ALIAS_NOT_UNIQUE';
         PA_UTILS.Add_Message ('PA', x_error_msg_data, 'PLAN_RES', g_token);
         Return;
    END IF;
 END IF;

-- Check to see if enabling this resource is allowed, if enabled flag = 'Y'
-- Fixes bug 3710822
-- --hr_utility.trace_on(null, 'RMENABLE');
-- --hr_utility.trace('hdjhjdhdkahdkahdk - start');
-- --hr_utility.trace('p_enabled_flag is : ' || p_enabled_flag);
IF p_enabled_flag = 'Y' THEN
   l_allowed := pa_planning_resource_utils.check_enable_allowed(
                   p_resource_list_member_id => p_resource_list_member_id);

-- --hr_utility.trace('l_allowed is : ' || l_allowed);
   IF l_allowed = 'N' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_data := 'PA_ENABLE_NOT_ALLOWED';
      PA_UTILS.Add_Message ('PA', x_error_msg_data, 'PLAN_RES', g_token);
-- --hr_utility.trace('x_error_msg_data is : ' || x_error_msg_data);
      Return;
   END IF;
END IF;

 /************************************
 * If it is Unique we go ahead with the Update to
 * pa_resource_list_members table.
 * Update using the values passed.
 *****************************************/

 pa_res_list_members_pkg.update_row
      (p_alias                    => l_resource_alias,
       p_enabled_flag             => p_enabled_flag,
       p_resource_list_member_id  =>  p_resource_list_member_id,
       p_spread_curve_id          => p_spread_curve_id,
       p_etc_method_code          => p_etc_method_code,
       p_mfc_cost_type_id         => p_mfc_cost_type_id,
       p_attribute_category       =>  p_attribute_category,
       p_attribute1               => p_attribute1,
       p_attribute2               => p_attribute2,
       p_attribute3               => p_attribute3,
       p_attribute4               => p_attribute4,
       p_attribute5               => p_attribute5,
       p_attribute6               => p_attribute6,
       p_attribute7              => p_attribute7,
       p_attribute8               => p_attribute8,
       p_attribute9               => p_attribute9,
       p_attribute10              => p_attribute10,
       p_attribute11              => p_attribute11,
       p_attribute12              => p_attribute12,
       p_attribute13              => p_attribute13,
       p_attribute14              => p_attribute14,
       p_attribute15              => p_attribute15,
       p_attribute16              => p_attribute16,
       p_attribute17              => p_attribute17,
       p_attribute18              => p_attribute18,
       p_attribute19              => p_attribute19,
       p_attribute20              => p_attribute20,
       p_attribute21              => p_attribute21,
       p_attribute22              => p_attribute22,
       p_attribute23              => p_attribute23,
       p_attribute24              => p_attribute24,
       p_attribute25              => p_attribute25,
       p_attribute26              => p_attribute26,
       p_attribute27              => p_attribute27,
       p_attribute28              => p_attribute28,
        p_attribute29             => p_attribute29,
       p_attribute30              => p_attribute30,
       p_record_version_number    => p_record_version_number,
       x_return_status            => x_return_status,
       x_error_msg_data           => x_error_msg_data,
       x_msg_count                => x_msg_count);


       x_record_version_number := p_record_version_number;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count :=  x_msg_count + 1;
           RETURN;
      END IF;

END Update_Planning_Resource;
/************************************************/

/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 *              delete a planning resource if it is not
 *              being used, else disable it.
 ***************************************************/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN   NUMBER,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data                 OUT NOCOPY  VARCHAR2)
IS
   l_exist_res_list    VARCHAR2(30) := 'N';
   l_resource_list_id  NUMBER;
   l_migration_code    VARCHAR2(30) := NULL;
   l_msg_count         NUMBER := 0;
BEGIN
IF g_amg_flow = 'N' OR g_amg_flow IS NULL THEN
   SELECT meaning || ' '
   INTO   g_token
   FROM   pa_lookups
   WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
   AND    lookup_code = 'PLANNING_RESOURCE';

   g_token := g_token || PA_PLANNING_RESOURCE_UTILS.Get_Plan_Res_Combination(
                  P_Resource_List_Member_Id => P_Resource_List_Member_Id);
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_count := 0;

BEGIN
SELECT resource_list_id, migration_code
INTO   l_resource_list_id, l_migration_code
FROM   pa_resource_list_members
WHERE  resource_list_member_id = p_resource_list_member_id;

EXCEPTION WHEN OTHERS THEN
   RETURN;
END;

/********************************************
 * To Check if resource_list member is currently being
 * used in a planning transaction.
 * We are checking from pa_resource_assignments table.
 ************************************************/
   BEGIN
       /*********************************************************
        * Bug         : 3485415
        * Description : Added the extra UNION condition to check from
        *               the Pa_project_assignments table as well before
        *               deleting. If the resource list member
        *               found in either pa_resource_assignments
        *               or pa_project_assignments we cannot delete
        *               it. We will only set the enabled_flag = 'Y'.
        **********************************************************/
       SELECT 'Y'
       INTO l_exist_res_list
       FROM DUAL
       WHERE EXISTS
       (SELECT 'Y' from pa_resource_assignments
       WHERE resource_list_member_id = p_resource_list_member_id
       UNION
       SELECT 'Y' from pa_project_assignments
       WHERE resource_list_member_id = p_resource_list_member_id );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_exist_res_list := 'N';
    WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name =>
         'pa_planning_resource_pvt.delete_planning_resource'
         ,p_procedure_name => PA_DEBUG.G_Err_Stack);
         l_msg_count := l_msg_count + 1;
         x_msg_count := l_msg_count;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;

    IF l_exist_res_list = 'N' THEN

       IF l_migration_code <> 'N' THEN

          PA_GET_RESOURCE.delete_resource_list_member_ok(
           l_resource_list_id        => l_resource_list_id,
           l_resource_list_member_id => p_resource_list_member_id,
           x_err_code                => x_msg_count,
           x_err_stage               => x_error_msg_data);

          IF x_msg_count <> 0 THEN
             l_exist_res_list := 'Y';
          END IF;
       END IF;

    END IF;

    pa_res_list_members_pkg.Delete_row
       (p_resource_list_member_id => p_resource_list_member_id,
        p_exist_res_list          => l_exist_res_list,
        x_msg_count               => x_msg_count,
        x_return_status           => x_return_status);

END Delete_Planning_Resource;
/***************************/
/*************************************************************
 * Procedure : Copy_Planning_Resources
 * Description : This API is used to copy the resource list
 *               members passed(as a table) from the source
 *               resource list ID to the destination resource
 *               list ID.
 *               It is called from the Task Assignments code when
 *               task assignments are copied from an external project
 *               to the current project - the transactions are also
 *               copied and so the planning resources also have to be
 *               copied from the source project's resource list to
 *               the destination project's resource list - only project
 *               specific resources will be copied, and the newly
 *               created resources will have the object_id of the destination
 *               project.  Only resources whose formats are on the
 *               destination list are copied.
 *               Steps :-
 *               - It first gets the format for the resource
 *               list member passed.
 *               - It then checks if the same format is being
 *               used by the destination resource list ID.
 *               - IF it does use it then check if there
 *               already exist a planning resource in the
 *               destination resource list having the same
 *               combination.
 *               - If it does then pass it back.
 *               - If it does not then create it and pass it back.
 *               - If the res_format_id does not exist
 *                 then pass back a Null resource list member id.
 *               - Do a final check to see that the out Tbl
 *                 size equals the IN Tbl size.
 *************************************************************/

-- Modified the procedure to operate in bulk mode for performance issues
-- as reported in the bug 4102957.

PROCEDURE Copy_Planning_Resources(
        p_source_resource_list_id       IN  Number,
        p_destination_resource_list_id  IN  Number,
        p_src_res_list_member_id_tbl    IN  SYSTEM.PA_NUM_TBL_TYPE,
        x_dest_res_list_member_id_tbl   OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
        p_destination_project_id        IN  Number DEFAULT NULL)
IS

  /**********************************
  * Local Variable
  **********************************/
  l_control_flag                 Varchar2(1);
  l_object_id                    Number;
  l_object_type                  VARCHAR2(30);
  l_exception                    EXCEPTION;
  l_bulk_resource_list_member_id SYSTEM.PA_NUM_TBL_TYPE;
  l_bulk_enabled_flag            SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
  l_old_resource_list_member_id  SYSTEM.PA_NUM_TBL_TYPE;
  l_new_resource_list_member_id  SYSTEM.PA_NUM_TBL_TYPE;
  l_last_analyzed                all_tables.last_analyzed%TYPE;
  l_pa_schema                    VARCHAR2(30);
BEGIN

--hr_utility.trace_on(NULL, 'RMP1');
--hr_utility.trace('START');
--hr_utility.trace('p_source_resource_list_id IS : ' || p_source_resource_list_id);
--hr_utility.trace('p_destination_resource_list_id IS : ' || p_destination_resource_list_id);
--hr_utility.trace('p_destination_project_id IS : ' || p_destination_project_id);
   x_dest_res_list_member_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();

   /*******************************************
   * If no resource list member ID's passed then
   * Just Return without doing anything.
   *****************************************/
   IF p_src_res_list_member_id_tbl.count = 0 THEN
      Return;
   END IF;

--hr_utility.trace('count is ' || p_src_res_list_member_id_tbl.count);
   -- COUNT is greater than 0 - initialize out table to be same size
   x_dest_res_list_member_id_tbl.extend(p_src_res_list_member_id_tbl.count);

   -- Bug 3642940
   BEGIN
      SELECT control_flag
      INTO l_control_flag
      FROM pa_resource_lists_all_bg
      WHERE resource_list_id = p_destination_resource_list_id;
   END;

   /*********************************************
    * The below select would be used to determine the
    * uniqueness of the resource within the resource list.
    *********************************************/
   -- Bug 3642940
   IF l_control_flag = 'Y' THEN
      l_object_id := p_destination_resource_list_id;
      l_object_type   := 'RESOURCE_LIST';
   ELSE
      l_object_id := p_destination_project_id;
      l_object_type   := 'PROJECT';
   END IF;

   -- Setting statistics for temp tables:
   -- bug 4887312
   -- ***** TEMP fix - proper fix will be done later
   -- Bug 4887312
/*
      FND_STATS.SET_TABLE_STATS('PA',
                          'PA_RES_MEMBERS_TEMP',
                           100,
                           10,
                           100);

      FND_STATS.SET_TABLE_STATS('PA',
                          'PA_RES_MEMBER_ID_TEMP',
                           100,
                           10,
                           100);
*/
    -- Proper Fix for 4887312 *** RAMURTHY  03/01/06 02:33 pm ***
    -- It solves the issue above wrt commit by the FND_STATS.SET_TABLE_STATS call

    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RES_MEMBERS_TEMP',100,10,100);
    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RES_MEMBER_ID_TEMP',100,10,100);

    -- End Bug fix 4887312
   /***********************************************
    * Deleting from the temp tables in the beginning as well
    * to be on the safe side.
    ***********************************************/
   DELETE FROM pa_res_members_temp;

   DELETE FROM pa_res_member_id_temp;
   /*************************************************/

   -- Looping through the source Resource list member ID table
   -- and inserting the values to
   -- the temp table pa_res_member_id_temp.

   IF p_src_res_list_member_id_tbl.count > 0 THEN

      FOR i IN p_src_res_list_member_id_tbl.first ..
               p_src_res_list_member_id_tbl.last
      LOOP
--hr_utility.trace('p_src_res_list_member_id_tbl(i) IS : ' || p_src_res_list_member_id_tbl(i));
         INSERT INTO pa_res_member_id_temp
             (resource_list_member_id,
              order_id)
         VALUES(p_src_res_list_member_id_tbl(i),
               i);
      END LOOP;

   END IF;

   -- Inserting Null for ORG_ID. Later ORG_ID will be popluated
   -- with values for corresponding
   -- RLM's which has a match in the destination list.

--hr_utility.trace('before temp insert');
   INSERT INTO pa_res_members_temp
          (resource_list_member_id           ,
           order_id                          ,
           person_id                         ,
           project_role_id                   ,
           organization_id                   ,
           job_id                            ,
           vendor_id                         ,
           inventory_item_id                 ,
           item_category_id                  ,
           bom_resource_id                   ,
           person_type_code                  ,
           -- named_role is holding team role
           named_role                        ,
           incurred_by_res_flag              ,
           incur_by_res_class_code           ,
           incur_by_role_id                  ,
           expenditure_type                  ,
           Event_type                        ,
           non_labor_resource                ,
           expenditure_category              ,
           revenue_category                  ,
           org_id                            ,
           resource_class_id                 ,
           -- Spread curve id is holding format id.
           spread_curve_id                   )
   SELECT  /*+ ORDERED */
           a.resource_list_member_id         ,
           b.order_id                        ,
           a.person_id                       ,
           a.project_role_id                 ,
           a.organization_id                 ,
           a.job_id                          ,
           a.vendor_id                       ,
           a.inventory_item_id               ,
           a.item_category_id                ,
           a.bom_resource_id                 ,
           a.person_type_code                ,
           a.team_role                       ,
           a.incurred_by_res_flag            ,
           a.incur_by_res_class_code         ,
           a.incur_by_role_id                ,
           a.expenditure_type                ,
           a.event_type                      ,
           a.non_labor_resource              ,
           a.expenditure_category            ,
           a.revenue_category                ,
           NULL                              ,
           a.resource_class_id               ,
           a.res_format_id
   FROM    pa_res_member_id_temp b,
           pa_resource_list_members a
   WHERE   a.resource_list_member_id = b.resource_list_member_id;

   -- Updating the ORG ID column to be -1 for those RLM's whose formats
   -- don't exist on the destination list:

   UPDATE pa_res_members_temp rlmtmp
   SET org_id = -1
   WHERE NOT EXISTS (
      SELECT 'Y'
      FROM   Pa_Plan_rl_formats
      WHERE  res_format_id = rlmtmp.spread_curve_id
      AND    resource_list_id = p_destination_resource_list_id
      AND    rownum = 1);

   -- Now, the temp tables are having all the details for every
   -- resource list member in the IN table. The ones with
   -- ORG_ID as NULL needs to be processed.

   -- Used four PL/SQL tables :
   -- l_bulk_resource_list_member_id : Holds the RLM id of the
   -- destination list which matches with source RLM id's.
   -- l_bulk_enabled_flag            : Holds the flag value of
   -- enabled_flag of destination RLM id's.
   -- l_old_resource_list_member_id  : Holds the RLM ids of the
   -- source list which has a match with destination RLM id's.
   -- l_new_resource_list_member_id  : Holds the RLM ids of the
   -- newly created members.

   SELECT a.resource_list_member_id,  -- matching rlm on dest
          a.enabled_flag,             -- enabled flag of match
          b.resource_list_member_id   -- matching rlm on source list
   BULK COLLECT INTO l_bulk_resource_list_member_id,
                     l_bulk_enabled_flag,
                     l_old_resource_list_member_id
   FROM   pa_resource_list_members a,
          pa_res_members_temp b
   WHERE  a.resource_list_id = p_destination_resource_list_id
   -- To process only those RLM which has corr formats as that of source RL.
   AND b.org_id IS NULL
   AND a.res_format_id = b.spread_curve_id
   AND a.object_type = l_object_type
   And a.object_id   = l_object_id
   And a.resource_class_id   = b.resource_class_id
   And nvl(a.person_id, -99) = nvl(b.person_id, -99)
   And nvl(a.organization_id, -99) =
       nvl(b.organization_id, -99)
   And nvl(a.job_id, -99) = nvl(b.job_id, -99)
   And nvl(a.vendor_id, -99) = nvl(b.vendor_id, -99)
   And nvl(a.inventory_item_id, -99) =
       nvl(b.inventory_item_id, -99)
   And nvl(a.item_category_id, -99) =
       nvl(b.item_category_id, -99)
   And nvl(a.bom_resource_id, -99) =
       nvl(b.bom_resource_id, -99)
   And nvl(a.person_type_code, 'DUMMY') =
       nvl(b.person_type_code, 'DUMMY')
   And nvl(a.team_role, 'DUMMY') =
       nvl(b.named_role, 'DUMMY')
   And nvl(a.incurred_by_res_flag, 'B') =
       nvl(b.incurred_by_res_flag, 'B')
   And nvl(a.incur_by_res_class_code, 'DUMMY') =
       nvl(b.incur_by_res_class_code,'DUMMY')
   And nvl(a.incur_by_role_id, -99) =
       nvl(b.incur_by_role_id, -99)
   And nvl(a.expenditure_type,'DUMMY') =
       nvl(b.expenditure_type, 'DUMMY')
   And nvl(a.event_type, 'DUMMY') =  nvl(b.event_type, 'DUMMY')
   And nvl(a.non_labor_resource, 'DUMMY') =
       nvl(b.non_labor_resource, 'DUMMY')
   And nvl(a.expenditure_category, 'DUMMY') =
       nvl(b.expenditure_category,'DUMMY')
   And nvl(a.revenue_category, 'DUMMY') =
       nvl(b.revenue_category, 'DUMMY');

   -- The table l_bulk_resource_list_member_id is having the
   -- corresponding RLM's for the source RLM's
   -- which have a match on destination.

   -- The temp table(ORG_ID) is updated to keep track of the matching
   -- resource list member id's.

--hr_utility.trace('l_bulk_resource_list_member_id.count is ' || l_bulk_resource_list_member_id.count);
   IF l_bulk_resource_list_member_id.count > 0 THEN

      FORALL j IN l_bulk_resource_list_member_id.first ..
                  l_bulk_resource_list_member_id.last
         UPDATE pa_res_members_temp
         SET org_id = DECODE(l_bulk_enabled_flag(j), 'Y' ,
                             l_bulk_resource_list_member_id(j),-1)
         WHERE resource_list_member_id = l_old_resource_list_member_id(j);

   END IF;

   -- So now, in pa_res_members_temp, All the source RLM's which have a match,
   -- have ORG_ID NOT NULL - if it is enabled, it is the RLM ID of the
   -- destination RLM; if it is not enabled it is -1, a dummy value which
   -- is converted to NULL later.

   -- There are now records in pa_res_members_temp where ORG_ID
   -- is NULL - these are source RLM's which don't have a match.
   -- They are created
   -- if the list is not centrally controlled.

   IF l_control_flag <> 'Y' THEN

      -- Getting the source ID's without a match.

      l_bulk_resource_list_member_id.delete; -- initializing the table

      SELECT DISTINCT resource_list_member_id
      BULK COLLECT INTO l_bulk_resource_list_member_id
      FROM pa_res_members_temp
      WHERE org_id IS NULL;

      l_new_resource_list_member_id := SYSTEM.PA_NUM_TBL_TYPE();
      l_new_resource_list_member_id.extend(
                           l_bulk_resource_list_member_id.count);

      IF l_bulk_resource_list_member_id.count > 0 THEN

         FOR i IN l_bulk_resource_list_member_id.first ..
                  l_bulk_resource_list_member_id.last
         LOOP
            SELECT pa_resource_list_members_s.NEXTVAL
            INTO l_new_resource_list_member_id(i)
            FROM dual;
         END LOOP;

      END IF;


      IF l_bulk_resource_list_member_id.count > 0 THEN

--hr_utility.trace('INSIDE IF l_bulk_resource_list_member_id.count is ' || l_bulk_resource_list_member_id.count);
         FORALL k IN l_bulk_resource_list_member_id.first ..
                     l_bulk_resource_list_member_id.last

            INSERT INTO PA_RESOURCE_LIST_MEMBERS
                  ( RESOURCE_LIST_MEMBER_ID  ,
                    RESOURCE_LIST_ID         ,
                    RESOURCE_ID              ,
                    ALIAS                    ,
                    DISPLAY_FLAG             ,
                    ENABLED_FLAG             ,
                    TRACK_AS_LABOR_FLAG      ,
                    PERSON_ID                ,
                    JOB_ID                   ,
                    ORGANIZATION_ID          ,
                    VENDOR_ID                ,
                    EXPENDITURE_TYPE         ,
                    EVENT_TYPE               ,
                    NON_LABOR_RESOURCE       ,
                    EXPENDITURE_CATEGORY     ,
                    REVENUE_CATEGORY         ,
                    PROJECT_ROLE_ID          ,
                    OBJECT_TYPE              ,
                    OBJECT_ID                ,
                    RESOURCE_CLASS_ID        ,
                    RESOURCE_CLASS_CODE      ,
                    RES_FORMAT_ID            ,
                    SPREAD_CURVE_ID          ,
                    ETC_METHOD_CODE          ,
                    MFC_COST_TYPE_ID         ,
                    COPY_FROM_RL_FLAG        ,
                    RESOURCE_CLASS_FLAG      ,
                    FC_RES_TYPE_CODE         ,
                    INVENTORY_ITEM_ID        ,
                    ITEM_CATEGORY_ID         ,
                    MIGRATION_CODE           ,
                    ATTRIBUTE_CATEGORY       ,
                    ATTRIBUTE1               ,
                    ATTRIBUTE2               ,
                    ATTRIBUTE3               ,
                    ATTRIBUTE4               ,
                    ATTRIBUTE5               ,
                    ATTRIBUTE6               ,
                    ATTRIBUTE7               ,
                    ATTRIBUTE8               ,
                    ATTRIBUTE9               ,
                    ATTRIBUTE10              ,
                    ATTRIBUTE11              ,
                    ATTRIBUTE12              ,
                    ATTRIBUTE13              ,
                    ATTRIBUTE14              ,
                    ATTRIBUTE15              ,
                    ATTRIBUTE16              ,
                    ATTRIBUTE17              ,
                    ATTRIBUTE18              ,
                    ATTRIBUTE19              ,
                    ATTRIBUTE20              ,
                    ATTRIBUTE21              ,
                    ATTRIBUTE22              ,
                    ATTRIBUTE23              ,
                    ATTRIBUTE24              ,
                    ATTRIBUTE25              ,
                    ATTRIBUTE26              ,
                    ATTRIBUTE27              ,
                    ATTRIBUTE28              ,
                    ATTRIBUTE29              ,
                    ATTRIBUTE30              ,
                    RECORD_VERSION_NUMBER    ,
                    PERSON_TYPE_CODE         ,
                    BOM_RESOURCE_ID          ,
                    TEAM_ROLE                ,
                    INCURRED_BY_RES_FLAG     ,
                    INCUR_BY_RES_CLASS_CODE  ,
                    INCUR_BY_ROLE_ID         ,
                    WP_ELIGIBLE_FLAG         ,
                    UNIT_OF_MEASURE          ,
                    LAST_UPDATED_BY          ,
                    LAST_UPDATE_DATE         ,
                    CREATION_DATE            ,
                    CREATED_BY               ,
                    LAST_UPDATE_LOGIN        )
            SELECT
                   l_new_resource_list_member_id(k)  ,
                   p_destination_resource_list_id    ,
                   a.resource_id                     ,
                   a.alias                           ,
                   a.display_flag                    ,
                   a.enabled_flag                    ,
                   a.track_as_labor_flag             ,
                   a.person_id                       ,
                   a.job_id                          ,
                   a.organization_id                 ,
                   a.vendor_id                       ,
                   a.expenditure_type                ,
                   a.event_type                      ,
                   a.non_labor_resource              ,
                   a.expenditure_category            ,
                   a.revenue_category                ,
                   a.project_role_id                 ,
                   'PROJECT'                         ,
                   p_destination_project_id          ,
                   a.resource_class_id               ,
                   a.resource_class_code             ,
                   a.res_format_id                   ,
                   a.spread_curve_id                 ,
                   a.etc_method_code                 ,
                   a.mfc_cost_type_id                ,
                   a.copy_from_rl_flag               ,
                   a.resource_class_flag             ,
                   a.fc_res_type_code                ,
                   a.inventory_item_id               ,
                   a.item_category_id                ,
                   a.migration_code                  ,
                   a.attribute_category              ,
                   a.attribute1                      ,
                   a.attribute2                      ,
                   a.attribute3                      ,
                   a.attribute4                      ,
                   a.attribute5                      ,
                   a.attribute6                      ,
                   a.attribute7                      ,
                   a.attribute8                      ,
                   a.attribute9                      ,
                   a.attribute10                     ,
                   a.attribute11                     ,
                   a.attribute12                     ,
                   a.attribute13                     ,
                   a.attribute14                     ,
                   a.attribute15                     ,
                   a.attribute16                     ,
                   a.attribute17                     ,
                   a.attribute18                     ,
                   a.attribute19                     ,
                   a.attribute20                     ,
                   a.attribute21                     ,
                   a.attribute22                     ,
                   a.attribute23                     ,
                   a.attribute24                     ,
                   a.attribute25                     ,
                   a.attribute26                     ,
                   a.attribute27                     ,
                   a.attribute28                     ,
                   a.attribute29                     ,
                   a.attribute30                     ,
                   a.record_version_number           ,
                   a.person_type_code                ,
                   a.bom_resource_id                 ,
                   a.team_role                       ,
                   a.incurred_by_res_flag            ,
                   a.incur_by_res_class_code         ,
                   a.incur_by_role_id                ,
                   a.wp_eligible_flag                ,
                   a.unit_of_measure                 ,
                   FND_GLOBAL.USER_ID                ,
                   SYSDATE                           ,
                   SYSDATE                           ,
                   FND_GLOBAL.USER_ID                ,
                   FND_GLOBAL.LOGIN_ID
            FROM   pa_resource_list_members a
            WHERE  a.resource_list_id = p_source_resource_list_id
            AND    a.resource_list_member_id =
                   l_bulk_resource_list_member_id(k);

         END IF;

      -- The table l_new_resource_list_member_id has the newly created RLM ID
      -- for the source RLM's that didn't have a match, which are in
      -- l_bulk_resource_list_member_id.
      -- Updating the temp table with this information.

      IF l_bulk_resource_list_member_id.count > 0 THEN

         FORALL x IN l_bulk_resource_list_member_id.first ..
                     l_bulk_resource_list_member_id.last
            UPDATE pa_res_members_temp
            SET org_id = l_new_resource_list_member_id(x)
            WHERE resource_list_member_id = l_bulk_resource_list_member_id(x);

      END IF;

   END IF; -- (l_control_flag <> 'Y')

   -- Converting the -1's to NULL

   UPDATE pa_res_members_temp
   SET    org_id = NULL
   WHERE  org_id = -1;

   -- Now, each record in the temp table has the value for ORG_ID that we
   -- are passing back in the out table - either a NULL or an RLM ID (new
   -- or existing):
   -- Populating the out table.

   SELECT a.org_id
   BULK COLLECT INTO x_dest_res_list_member_id_tbl
   FROM pa_res_members_temp a,
        pa_res_member_id_temp b
   WHERE a.resource_list_member_id = b.resource_list_member_id
   AND a.order_id  = b.order_id
   ORDER BY b.order_id;

   IF p_src_res_list_member_id_tbl.count <>
      x_dest_res_list_member_id_tbl.count
   THEN
      RAISE l_exception;
   END IF;
   -- Clearing Temp tables
   DELETE FROM pa_res_members_temp;

   DELETE FROM pa_res_member_id_temp;


EXCEPTION
   WHEN l_exception THEN
      FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'Pa_Planning_Resource_Pvt'
              ,p_procedure_name => 'Copy_Planning_Resources');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Copy_Planning_Resources;

/******************************/

END Pa_Planning_Resource_Pvt;
/**************************/

/
