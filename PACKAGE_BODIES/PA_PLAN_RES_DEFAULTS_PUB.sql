--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RES_DEFAULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RES_DEFAULTS_PUB" as
/* $Header: PARPRDPB.pls 120.1 2007/02/06 09:55:49 dthakker ship $ */
procedure UPDATE_RESOURCE_DEFAULTS (
  P_PLAN_RES_DEF_ID_TBL             IN system.pa_num_tbl_type   ,
  P_RESOURCE_CLASS_ID_TBL           IN system.pa_num_tbl_type   ,
  P_OBJECT_TYPE_TBL                 IN system.pa_varchar2_30_tbl_type ,
  P_OBJECT_ID_TBL                   IN system.pa_num_tbl_type   ,
  P_SPREAD_CURVE_ID_TBL             IN system.pa_num_tbl_type   ,
  P_ETC_METHOD_CODE_TBL             IN system.pa_varchar2_30_tbl_type ,
  P_EXPENDITURE_TYPE_TBL            IN system.pa_varchar2_30_tbl_type   ,
  P_ITEM_CATEGORY_SET_ID_TBL        IN system.pa_num_tbl_type   ,
  P_ITEM_MASTER_ID_TBL              IN system.pa_num_tbl_type   ,
  P_MFC_COST_TYPE_ID_TBL            IN system.pa_num_tbl_type   ,
  P_ENABLED_FLAG_TBL                IN system.pa_varchar2_1_tbl_type ,
  X_RECORD_VERSION_NUMBER_TBL       IN OUT NOCOPY system.pa_num_tbl_type   ,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2
) is

l_item_master_id       NUMBER;
l_item_category_set_id NUMBER;
l_master_used          VARCHAR2(1) := 'N';
l_category_used        VARCHAR2(1) := 'N';
l_master_error         EXCEPTION;
l_category_error       EXCEPTION;
l_invalid_cat_set      EXCEPTION;		-- Bug 3768550
l_cat_flag             VARCHAR2(1) := 'N';	-- Bug 3768550
l_cat_name             VARCHAR2(30);	        -- Bug 3768550
begin
-- Initialize the error stack.
fnd_msg_pub.initialize;

--hr_utility.trace_on(NULL, 'RMCL');
--hr_utility.trace('strt update');
x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF P_PLAN_RES_DEF_ID_TBL.COUNT > 0 THEN
   FOR i IN P_PLAN_RES_DEF_ID_TBL.FIRST .. P_PLAN_RES_DEF_ID_TBL.LAST LOOP
--hr_utility.trace('in first if ');
      -- Get the existing Item Master and Item Category.
      BEGIN
      select ITEM_CATEGORY_SET_ID, ITEM_MASTER_ID
        into l_item_category_set_id, l_item_master_id
        from PA_PLAN_RES_DEFAULTS
       where PLAN_RES_DEFAULT_ID = P_PLAN_RES_DEF_ID_TBL(i);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := x_msg_count + 1;
            RETURN;
            --FND_MSG_PUB.add_exc_msg(
               --p_pkg_name         => 'pa_plan_res_defaults_pub',
               --p_procedure_name   => 'UPDATE_RESOURCE_DEFAULTS');
      END;
      -- Check whether Item Master is used anywhere
      IF l_item_master_id IS NOT NULL THEN
--hr_utility.trace('l_item_master_id is not null ');
         IF l_item_master_id <> nvl(P_ITEM_MASTER_ID_TBL(i), -99) THEN

            IF (PA_DELIVERABLE_UTILS.IS_ITEM_BASED_DLV_EXISTS = 'Y') THEN
               l_master_used := 'Y';
            ELSE
--hr_utility.trace('l_item_master_id is | ' || l_item_master_id);
--hr_utility.trace('P_ITEM_MASTER_ID_TBL(i) is | ' || P_ITEM_MASTER_ID_TBL(i));
                BEGIN
                select 'Y'
                  into l_master_used
                  from pa_res_formats_b format,
                       pa_res_types_b types
                 where types.res_type_code = 'INVENTORY_ITEM'
                   and types.res_type_id = format.res_type_id
                   and exists (select 'Y'
                                 from PA_RESOURCE_LIST_MEMBERS rlm
                                where rlm.res_format_id = format.res_format_id);
                                  --and rlm.inventory_item_id is not null)
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      l_master_used := 'N';
                   WHEN TOO_MANY_ROWS THEN
		      l_master_used := 'Y';
                END;
            END IF;
         END IF;
      END IF;

      IF (l_master_used = 'Y') THEN
--hr_utility.trace('l_master_error ');
         raise l_master_error;
      END IF;

      -- Check whether Item Category is used anywhere
      IF l_item_category_set_id IS NOT NULL THEN
         IF l_item_category_set_id <>
            nvl(P_ITEM_CATEGORY_SET_ID_TBL(i), -99) THEN

--hr_utility.trace('l_item_category_set_id is not null ');
--hr_utility.trace('l_item_category_set_id is | ' || l_item_category_set_id);
--hr_utility.trace('P_ITEM_CATEGORY_SET_ID_TBL(i) is | ' || P_ITEM_CATEGORY_SET_ID_TBL(i));
--hr_utility.trace('length of P_ITEM_CATEGORY_SET_ID_TBL(i) is | ' || length(P_ITEM_CATEGORY_SET_ID_TBL(i)));
                -- Begin changes for bug 3768550
                -- Check whether the default for item category set has had its
                -- MULT_ITEM_CAT_ASSIGN_FLAG changed from N to Y making it
                -- ineligible and raise a specific error.
                IF (P_ITEM_CATEGORY_SET_ID_TBL(i) IS NULL OR
                    (P_ITEM_CATEGORY_SET_ID_TBL(i) = 0)) THEN
--hr_utility.trace('in new check');
                   BEGIN
                   SELECT MULT_ITEM_CAT_ASSIGN_FLAG, CATEGORY_SET_NAME
                     INTO l_cat_flag, l_cat_name
                     FROM mtl_category_sets_vl
                    WHERE category_set_id = l_item_category_set_id;
	           EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                         raise l_invalid_cat_set;
                   END;
                   IF l_cat_flag = 'Y' THEN
                      raise l_invalid_cat_set;
                   END IF;
                END IF;
                -- end changes for bug 3768550

                BEGIN
                select 'Y'
                  into l_category_used
                  from pa_res_formats_b format,
                       pa_res_types_b types
                 where types.res_type_code = 'ITEM_CATEGORY'
                   and types.res_type_id = format.res_type_id
                   and exists (select 'Y'
                                 from PA_RESOURCE_LIST_MEMBERS rlm
                                where rlm.res_format_id = format.res_format_id);
                                  --and rlm.item_category_id is not null)
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      l_category_used := 'N';
                   WHEN TOO_MANY_ROWS THEN
		      l_category_used := 'Y';
                END;

         END IF;
      END IF;

      IF l_category_used = 'Y' THEN
         raise l_category_error;
      END IF;

--hr_utility.trace('before UPDATE_ROW ');
        pa_plan_res_defaults_pvt.UPDATE_ROW (
    P_PLAN_RES_DEFAULT_ID       => P_PLAN_RES_DEF_ID_TBL(i)          ,
    P_RESOURCE_CLASS_ID         => P_RESOURCE_CLASS_ID_TBL(i)        ,
    P_OBJECT_TYPE               => P_OBJECT_TYPE_TBL(i)              ,
    P_OBJECT_ID                 => P_OBJECT_ID_TBL(i)                ,
    P_SPREAD_CURVE_ID           => P_SPREAD_CURVE_ID_TBL(i)          ,
    P_ETC_METHOD_CODE           => P_ETC_METHOD_CODE_TBL(i)          ,
    P_EXPENDITURE_TYPE          => P_EXPENDITURE_TYPE_TBL(i)         ,
    P_ITEM_CATEGORY_SET_ID      => P_ITEM_CATEGORY_SET_ID_TBL(i)     ,
    P_ITEM_MASTER_ID            => P_ITEM_MASTER_ID_TBL(i)           ,
    P_MFC_COST_TYPE_ID          => P_MFC_COST_TYPE_ID_TBL(i)         ,
    P_ENABLED_FLAG              => P_ENABLED_FLAG_TBL(i)             ,
    X_RECORD_VERSION_NUMBER     => X_RECORD_VERSION_NUMBER_TBL(i)    ,
    P_LAST_UPDATE_DATE          => sysdate                    ,
    P_LAST_UPDATED_BY           => fnd_global.user_id         ,
    P_LAST_UPDATE_LOGIN         => fnd_global.user_id         ,
    x_return_status             => x_return_status            ,
    x_msg_count                 => x_msg_count                ,
    x_msg_data                  => x_msg_data);
--hr_utility.trace('x_return_status is | ' || x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       pa_utils.add_message('PA', x_msg_data);
       RETURN;
    END IF;
   END LOOP;
END IF;

EXCEPTION
   WHEN l_master_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PA_RES_ITEM_MASTER_USED';
      x_msg_count := x_msg_count + 1;
      pa_utils.add_message('PA', x_msg_data);
   WHEN l_invalid_cat_set THEN			-- Bug 3768550
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PA_RES_INV_ITEM_CAT_SET';
      x_msg_count := x_msg_count + 1;
      Pa_Utils.Add_Message(P_App_Short_Name => 'PA',
                           P_Msg_Name       => 'PA_RES_INV_ITEM_CAT_SET',
                           p_token1         => 'CAT_NAME',
                           p_value1         => l_cat_name);

   WHEN l_category_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PA_RES_ITEM_CATEGORY_USED';
      x_msg_count := x_msg_count + 1;
      pa_utils.add_message('PA', x_msg_data);
    WHEN OTHERS THEN
       -- FND_MSG_PUB.add_exc_msg(
       -- p_pkg_name => 'pa_plan_res_defaults_pub.UPDATE_RESOURCE_DEFAULTS'
       -- ,p_procedure_name => PA_DEBUG.G_Err_Stack);
       x_msg_count := x_msg_count + 1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_data := substr(SQLERRM, 1, 25);

end UPDATE_RESOURCE_DEFAULTS;

end pa_plan_res_defaults_pub;

/
