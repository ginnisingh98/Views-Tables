--------------------------------------------------------
--  DDL for Package Body INVPVLM3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVLM3" AS
/* $Header: INVPVM3B.pls 120.2 2005/08/23 22:32:31 lparihar ship $ */

FUNCTION validate_item_org7
(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id  IN     NUMBER  DEFAULT -999
)
return integer
is

        /*
        ** Retrieve column values for validation
        */

        CURSOR cc is
        select
         msii.TRANSACTION_ID,
         msii.INVENTORY_ITEM_ID III,
         msii.ORGANIZATION_ID ORGID,
         mp.MASTER_ORGANIZATION_ID MORGID,
         msii.NEGATIVE_MEASUREMENT_ERROR,
         msii.ENGINEERING_ECN_CODE,
         msii.ENGINEERING_ITEM_ID,
         msii.ENGINEERING_DATE,
         msii.SERVICE_STARTING_DELAY,
         msii.SERVICEABLE_COMPONENT_FLAG,
         msii.SERVICEABLE_PRODUCT_FLAG,
         msii.BASE_WARRANTY_SERVICE_ID,
         msii.PAYMENT_TERMS_ID,
         msii.PREVENTIVE_MAINTENANCE_FLAG,
         msii.PRIMARY_SPECIALIST_ID,
         msii.SECONDARY_SPECIALIST_ID,
         msii.SERVICEABLE_ITEM_CLASS_ID,
         msii.TIME_BILLABLE_FLAG,
         msii.MATERIAL_BILLABLE_FLAG,
         msii.EXPENSE_BILLABLE_FLAG,
         msii.PRORATE_SERVICE_FLAG,
         msii.COVERAGE_SCHEDULE_ID,
         msii.SERVICE_DURATION_PERIOD_CODE,
         msii.SERVICE_DURATION,
         msii.WARRANTY_VENDOR_ID,
         msii.MAX_WARRANTY_AMOUNT,
         msii.RESPONSE_TIME_PERIOD_CODE,
         msii.RESPONSE_TIME_VALUE,
         msii.NEW_REVISION_CODE,
         msii.INVOICEABLE_ITEM_FLAG,
         msii.TAX_CODE,
         msii.INVOICE_ENABLED_FLAG,
         msii.MUST_USE_APPROVED_VENDOR_FLAG,
         msii.RELEASE_TIME_FENCE_CODE,
         msii.RELEASE_TIME_FENCE_DAYS,
         msii.CONTAINER_ITEM_FLAG,
         msii.CONTAINER_TYPE_CODE,
         msii.INTERNAL_VOLUME,
         msii.MAXIMUM_LOAD_WEIGHT,
         msii.MINIMUM_FILL_PERCENT,
         msii.VEHICLE_ITEM_FLAG,
-- Added for 11.5.10
         msii.TRACKING_QUANTITY_IND ,
         msii.ONT_PRICING_QTY_SOURCE,
         msii.SECONDARY_DEFAULT_IND ,
         msii.CONFIG_ORGS,
         msii.CONFIG_MATCH,
         msii.VMI_MINIMUM_UNITS ,
         msii.VMI_MINIMUM_DAYS  ,
         msii.VMI_MAXIMUM_UNITS  ,
         msii.VMI_MAXIMUM_DAYS  ,
         msii.VMI_FIXED_ORDER_QUANTITY ,
         msii.SO_AUTHORIZATION_FLAG ,
         msii.CONSIGNED_FLAG       ,
         msii.ASN_AUTOEXPIRE_FLAG   ,
         msii.VMI_FORECAST_TYPE    ,
         msii.FORECAST_HORIZON      ,
         msii.EXCLUDE_FROM_BUDGET_FLAG ,
         msii.DAYS_TGT_INV_SUPPLY    ,
         msii.DAYS_TGT_INV_WINDOW    ,
         msii.DAYS_MAX_INV_SUPPLY    ,
         msii.DAYS_MAX_INV_WINDOW     ,
         msii.DRP_PLANNED_FLAG        ,
         msii.CRITICAL_COMPONENT_FLAG ,
         msii.CONTINOUS_TRANSFER    ,
         msii.CONVERGENCE         ,
         msii.DIVERGENCE          ,
         /* Start Bug 3713912 */
         msii.LOT_DIVISIBLE_FLAG                  ,
         msii.GRADE_CONTROL_FLAG                  ,
         msii.DEFAULT_GRADE                       ,
         msii.CHILD_LOT_FLAG                      ,
         msii.PARENT_CHILD_GENERATION_FLAG        ,
         msii.CHILD_LOT_PREFIX                    ,
         msii.CHILD_LOT_STARTING_NUMBER           ,
         msii.CHILD_LOT_VALIDATION_FLAG           ,
         msii.COPY_LOT_ATTRIBUTE_FLAG             ,
         msii.RECIPE_ENABLED_FLAG                 ,
         msii.PROCESS_QUALITY_ENABLED_FLAG        ,
         msii.PROCESS_EXECUTION_ENABLED_FLAG      ,
         msii.PROCESS_COSTING_ENABLED_FLAG        ,
         msii.PROCESS_SUPPLY_SUBINVENTORY         ,
         msii.PROCESS_SUPPLY_LOCATOR_ID           ,
         msii.PROCESS_YIELD_SUBINVENTORY          ,
         msii.PROCESS_YIELD_LOCATOR_ID            ,
         msii.HAZARDOUS_MATERIAL_FLAG             ,
         msii.CAS_NUMBER                          ,
         msii.RETEST_INTERVAL                     ,
         msii.EXPIRATION_ACTION_INTERVAL          ,
         msii.EXPIRATION_ACTION_CODE              ,
         msii.MATURITY_DAYS                       ,
         msii.HOLD_DAYS
         /* End Bug 3713912 */
        from MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
        where ((msii.organization_id = org_id) or
               (all_Org = 1))
        and   msii.process_flag = 2
        and   msii.organization_id = mp.organization_id
        and   msii.set_process_id = xset_id
        and   msii.organization_id <> mp.master_organization_id;

        /*
        ** Attributes that are Item level (can't be different from master org's value)
        */

        CURSOR ee is
        select attribute_name,
               control_level
        from MTL_ITEM_ATTRIBUTES
        where control_level = 1;

        msicount                number;
        msiicount               number;
        l_item_id               number;
        l_org_id                number;
        trans_id                number;
        ext_flag                number := 0;
        error_msg               varchar2(70);
        status                  number;
        dumm_status             number;
        master_org_id           number;
        LOGGING_ERR             exception;
        VALIDATE_ERR            exception;
        X_TRUE                  number := 1;

         A_NEGATIVE_MEASUREMENT_ERROR   number := 2;
         A_ENGINEERING_ECN_CODE         number := 2;
         A_ENGINEERING_ITEM_ID          number := 2;
         A_ENGINEERING_DATE             number := 2;
         A_SERVICE_STARTING_DELAY       number := 2;
         A_SERVICEABLE_COMPONENT_FLAG   number := 2;
         A_SERVICEABLE_PRODUCT_FLAG     number := 2;
         A_BASE_WARRANTY_SERVICE_ID     number := 2;
         A_PAYMENT_TERMS_ID             number := 2;
         A_PREVENTIVE_MAINTENANCE_FLAG  number := 2;
         A_PRIMARY_SPECIALIST_ID        number := 2;
         A_SECONDARY_SPECIALIST_ID      number := 2;
         A_SERVICEABLE_ITEM_CLASS_ID    number := 2;
         A_TIME_BILLABLE_FLAG           number := 2;
         A_MATERIAL_BILLABLE_FLAG       number := 2;
         A_EXPENSE_BILLABLE_FLAG        number := 2;
         A_PRORATE_SERVICE_FLAG         number := 2;
         A_COVERAGE_SCHEDULE_ID         number := 2;
         A_SERVICE_DURATION_PERIOD_CODE number := 2;
         A_SERVICE_DURATION             number := 2;
         A_WARRANTY_VENDOR_ID           number := 2;
         A_MAX_WARRANTY_AMOUNT          number := 2;
         A_RESPONSE_TIME_PERIOD_CODE    number := 2;
         A_RESPONSE_TIME_VALUE          number := 2;
         A_NEW_REVISION_CODE            number := 2;
         A_INVOICEABLE_ITEM_FLAG        number := 2;
         A_TAX_CODE                     number := 2;
         A_INVOICE_ENABLED_FLAG         number := 2;
         A_MUST_USE_APPROVED_VENDOR_F   number := 2;
         A_RELEASE_TIME_FENCE_CODE      number := 2;
         A_RELEASE_TIME_FENCE_DAYS      number := 2;
         A_CONTAINER_ITEM_FLAG          number := 2;
         A_CONTAINER_TYPE_CODE          number := 2;
         A_INTERNAL_VOLUME              number := 2;
         A_MAXIMUM_LOAD_WEIGHT          number := 2;
         A_MINIMUM_FILL_PERCENT         number := 2;
         A_VEHICLE_ITEM_FLAG            number := 2;
-- Added for 11.5.10
         A_TRACKING_QUANTITY_IND        number := 2;
         A_ONT_PRICING_QTY_SOURCE       number := 2;
         A_SECONDARY_DEFAULT_IND        number := 2;
         A_CONFIG_ORGS                  number := 2;
         A_CONFIG_MATCH                 number := 2;
        A_VMI_MINIMUM_UNITS             number   := 2;
        A_VMI_MINIMUM_DAYS              number   := 2;
        A_VMI_MAXIMUM_UNITS             number   := 2;
        A_VMI_MAXIMUM_DAYS              number   := 2;
        A_VMI_FIXED_ORDER_QUANTITY      number   := 2;
        A_SO_AUTHORIZATION_FLAG         number   := 2;
        A_CONSIGNED_FLAG                number   := 2;
        A_ASN_AUTOEXPIRE_FLAG           number   := 2;
        A_VMI_FORECAST_TYPE             number   := 2;
        A_FORECAST_HORIZON              number   := 2;
        A_EXCLUDE_FROM_BUDGET_FLAG      number   := 2;
        A_DAYS_TGT_INV_SUPPLY           number   := 2;
        A_DAYS_TGT_INV_WINDOW           number   := 2;
        A_DAYS_MAX_INV_SUPPLY           number   := 2;
        A_DAYS_MAX_INV_WINDOW           number   := 2;
        A_DRP_PLANNED_FLAG              number   := 2;
        A_CRITICAL_COMPONENT_FLAG       number   := 2;
        A_CONTINOUS_TRANSFER            number   := 2;
        A_CONVERGENCE                   number   := 2;
        A_DIVERGENCE                    number   := 2;

        /* Start Bug 3713912 */
        A_LOT_DIVISIBLE_FLAG                    NUMBER  := 2;
        A_GRADE_CONTROL_FLAG                    NUMBER  := 2;
        A_DEFAULT_GRADE                         NUMBER  := 2;
        A_CHILD_LOT_FLAG                        NUMBER  := 2;
        A_PARENT_CHILD_GENERATION_FLAG          NUMBER  := 2;
        A_CHILD_LOT_PREFIX                      NUMBER  := 2;
        A_CHILD_LOT_STARTING_NUMBER             NUMBER  := 2;
        A_CHILD_LOT_VALIDATION_FLAG             NUMBER  := 2;
        A_COPY_LOT_ATTRIBUTE_FLAG               NUMBER  := 2;
        A_RECIPE_ENABLED_FLAG                   NUMBER  := 2;
        A_PROCESS_QUALITY_ENABLED_FLAG          NUMBER  := 2;
        A_PROCESS_EXEC_ENABLED_FLAG             NUMBER  := 2;
        A_PROCESS_COSTING_ENABLED_FLAG          NUMBER  := 2;
        A_PROCESS_SUPPLY_SUBINVENTORY           NUMBER  := 2;
        A_PROCESS_SUPPLY_LOCATOR_ID             NUMBER  := 2;
        A_PROCESS_YIELD_SUBINVENTORY            NUMBER  := 2;
        A_PROCESS_YIELD_LOCATOR_ID              NUMBER  := 2;
        A_HAZARDOUS_MATERIAL_FLAG               NUMBER  := 2;
        A_CAS_NUMBER                            NUMBER  := 2;
        A_RETEST_INTERVAL                       NUMBER  := 2;
        A_EXPIRATION_ACTION_INTERVAL            NUMBER  := 2;
        A_EXPIRATION_ACTION_CODE                NUMBER  := 2;
        A_MATURITY_DAYS                         NUMBER  := 2;
        A_HOLD_DAYS                             NUMBER  := 2;

        /* End Bug 3713912 */

begin

        error_msg := 'Validation error in validating MTL_SYSTEM_ITEMS_INTERFACE with ';

/* set the attribute level variables to be used when validating a child's item
** level attributes against the master org's attribute value.  this is done
** outside the loop so that it is only done once for all the records
** instead of once PER record.
*/

        for att in ee loop
                if substr(att.attribute_name,18) = 'NEGATIVE_MEASUREMENT_ERROR' then
                        A_NEGATIVE_MEASUREMENT_ERROR := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'ENGINEERING_ECN_CODE' then
                        A_ENGINEERING_ECN_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'ENGINEERING_ITEM_ID' then
                        A_ENGINEERING_ITEM_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'ENGINEERING_DATE' then
                        A_ENGINEERING_DATE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICE_STARTING_DELAY' then
                        A_SERVICE_STARTING_DELAY := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICEABLE_COMPONENT_FLAG' then
                        A_SERVICEABLE_COMPONENT_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICEABLE_PRODUCT_FLAG' then
                        A_SERVICEABLE_PRODUCT_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'BASE_WARRANTY_SERVICE_ID' then
                        A_BASE_WARRANTY_SERVICE_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'PAYMENT_TERMS_ID' then
                        A_PAYMENT_TERMS_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'PREVENTIVE_MAINTENANCE_FLAG' then
                        A_PREVENTIVE_MAINTENANCE_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'PRIMARY_SPECIALIST_ID' then
                        A_PRIMARY_SPECIALIST_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SECONDARY_SPECIALIST_ID' then
                        A_SECONDARY_SPECIALIST_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICEABLE_ITEM_CLASS_ID' then
                        A_SERVICEABLE_ITEM_CLASS_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'TIME_BILLABLE_FLAG' then
                        A_TIME_BILLABLE_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'MATERIAL_BILLABLE_FLAG' then
                        A_MATERIAL_BILLABLE_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'EXPENSE_BILLABLE_FLAG' then
                        A_EXPENSE_BILLABLE_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'PRORATE_SERVICE_FLAG' then
                        A_PRORATE_SERVICE_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'COVERAGE_SCHEDULE_ID' then
                        A_COVERAGE_SCHEDULE_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICE_DURATION_PERIOD_CODE' then
                        A_SERVICE_DURATION_PERIOD_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SERVICE_DURATION' then
                        A_SERVICE_DURATION := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'WARRANTY_VENDOR_ID' then
                        A_WARRANTY_VENDOR_ID := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'MAX_WARRANTY_AMOUNT' then
                        A_MAX_WARRANTY_AMOUNT := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'RESPONSE_TIME_PERIOD_CODE' then
                        A_RESPONSE_TIME_PERIOD_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'RESPONSE_TIME_VALUE' then
                        A_RESPONSE_TIME_VALUE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'NEW_REVISION_CODE' then
                        A_NEW_REVISION_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'INVOICEABLE_ITEM_FLAG' then
                        A_INVOICEABLE_ITEM_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'TAX_CODE' then
                        A_TAX_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'INVOICE_ENABLED_FLAG' then
                        A_INVOICE_ENABLED_FLAG := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'MUST_USE_APPROVED_VENDOR_FLAG' then
                        A_MUST_USE_APPROVED_VENDOR_F := att.control_level;
                end if;
                /*NP 19AUG96 Eight new cols added for 10.7 */
                if substr(att.attribute_name,18) = 'RELEASE_TIME_FENCE_CODE' then
                        A_RELEASE_TIME_FENCE_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'RELEASE_TIME_FENCE_DAYS' then
                        A_RELEASE_TIME_FENCE_DAYS := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'CONTAINER_ITEM_FLAG' then
                         A_CONTAINER_ITEM_FLAG:= att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'CONTAINER_TYPE_CODE' then
                        A_CONTAINER_TYPE_CODE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'INTERNAL_VOLUME' then
                        A_INTERNAL_VOLUME := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'MAXIMUM_LOAD_WEIGHT' then
                        A_MAXIMUM_LOAD_WEIGHT := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'MINIMUM_FILL_PERCENT' then
                        A_MINIMUM_FILL_PERCENT := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'VEHICLE_ITEM_FLAG' then
                        A_VEHICLE_ITEM_FLAG := att.control_level;
                end if;
                /*New cols added for 11.5.10 */
                if substr(att.attribute_name,18) = 'TRACKING_QUANTITY_IND' then
                        A_TRACKING_QUANTITY_IND := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'ONT_PRICING_QTY_SOURCE' then
                        A_ONT_PRICING_QTY_SOURCE := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'SECONDARY_DEFAULT_IND' then
                         A_SECONDARY_DEFAULT_IND:= att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'CONFIG_ORGS' then
                        A_CONFIG_ORGS := att.control_level;
                end if;
                if substr(att.attribute_name,18) = 'CONFIG_MATCH' then
                         A_CONFIG_MATCH := att.control_level;
                end if;
              IF substr(att.attribute_name,18) = 'VMI_MINIMUM_UNITS' then
                 A_VMI_MINIMUM_UNITS := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'VMI_MINIMUM_DAYS' then
                 A_VMI_MINIMUM_DAYS := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'VMI_MAXIMUM_UNITS' then
                 A_VMI_MAXIMUM_UNITS := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'VMI_MAXIMUM_DAYS' then
                 A_VMI_MAXIMUM_DAYS := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'VMI_FIXED_ORDER_QUANTITY' then
                 A_VMI_FIXED_ORDER_QUANTITY := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'SO_AUTHORIZATION_FLAG' then
                 A_SO_AUTHORIZATION_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'CONSIGNED_FLAG' then
                 A_CONSIGNED_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'ASN_AUTOEXPIRE_FLAG' then
                 A_ASN_AUTOEXPIRE_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'VMI_FORECAST_TYPE' then
                 A_VMI_FORECAST_TYPE := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'FORECAST_HORIZON' then
                 A_FORECAST_HORIZON := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'EXCLUDE_FROM_BUDGET_FLAG' then
                 A_EXCLUDE_FROM_BUDGET_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DAYS_TGT_INV_SUPPLY' then
                 A_DAYS_TGT_INV_SUPPLY := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DAYS_TGT_INV_WINDOW' then
                 A_DAYS_TGT_INV_WINDOW := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DAYS_MAX_INV_SUPPLY' then
                 A_DAYS_MAX_INV_SUPPLY := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DAYS_MAX_INV_WINDOW' then
                 A_DAYS_MAX_INV_WINDOW := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DRP_PLANNED_FLAG' then
                 A_DRP_PLANNED_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'CRITICAL_COMPONENT_FLAG' then
                 A_CRITICAL_COMPONENT_FLAG := att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'CONTINOUS_TRANSFER' then
                 A_CONTINOUS_TRANSFER:= att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'CONVERGENCE' then
                 A_CONVERGENCE:= att.control_level;
              END IF;
              IF substr(att.attribute_name,18) = 'DIVERGENCE' then
                 A_DIVERGENCE:= att.control_level;
              END IF;

              /*Begin Bug 3713912 */
             IF substr(att.attribute_name,18) = 'LOT_DIVISIBLE_FLAG'  THEN
                  A_LOT_DIVISIBLE_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'GRADE_CONTROL_FLAG' THEN
                  A_GRADE_CONTROL_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'DEFAULT_GRADE' THEN
                  A_DEFAULT_GRADE := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'CHILD_LOT_FLAG' THEN
                  A_CHILD_LOT_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PARENT_CHILD_GENERATION_FLAG' THEN
                  A_PARENT_CHILD_GENERATION_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'CHILD_LOT_PREFIX' THEN
                  A_CHILD_LOT_PREFIX := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'CHILD_LOT_STARTING_NUMBER' THEN
                  A_CHILD_LOT_STARTING_NUMBER := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'CHILD_LOT_VALIDATION_FLAG' THEN
                  A_CHILD_LOT_VALIDATION_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'COPY_LOT_ATTRIBUTE_FLAG' THEN
                  A_COPY_LOT_ATTRIBUTE_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'RECIPE_ENABLED_FLAG' THEN
                  A_RECIPE_ENABLED_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_QUALITY_ENABLED_FLAG' THEN
                  A_PROCESS_QUALITY_ENABLED_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_EXECUTION_ENABLED_FLAG' THEN
                  A_PROCESS_EXEC_ENABLED_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_COSTING_ENABLED_FLAG' THEN
                  A_PROCESS_COSTING_ENABLED_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_SUPPLY_SUBINVENTORY' THEN
                  A_PROCESS_SUPPLY_SUBINVENTORY := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_SUPPLY_LOCATOR_ID' THEN
                  A_PROCESS_SUPPLY_LOCATOR_ID := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_YIELD_SUBINVENTORY' THEN
                  A_PROCESS_YIELD_SUBINVENTORY := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'PROCESS_YIELD_LOCATOR_ID' THEN
                  A_PROCESS_YIELD_LOCATOR_ID := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'HAZARDOUS_MATERIAL_FLAG' THEN
                  A_HAZARDOUS_MATERIAL_FLAG := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'CAS_NUMBER' THEN
                  A_CAS_NUMBER := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'RETEST_INTERVAL' THEN
                  A_RETEST_INTERVAL := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'EXPIRATION_ACTION_INTERVAL' THEN
                  A_EXPIRATION_ACTION_INTERVAL := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'EXPIRATION_ACTION_CODE' THEN
                  A_EXPIRATION_ACTION_CODE := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'MATURITY_DAYS' THEN
                  A_MATURITY_DAYS := att.control_level;
             END IF;
             IF substr(att.attribute_name,18) = 'HOLD_DAYS' THEN
                  A_HOLD_DAYS := att.control_level;
             END IF;
  /* End Bug 3713912 */

        end loop;

-- validate the records

        for cr in cc loop
                status := 0;
                trans_id := cr.transaction_id;
                l_org_id := cr.ORGID;

                begin /* MASTER_CHILD_7A */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_ENGINEERING_DATE,X_TRUE,nvl(cr.ENGINEERING_DATE,TO_DATE('1000/01/01','YYYY/MM/DD')),nvl(msi.ENGINEERING_DATE,TO_DATE('1000/01/01','YYYY/MM/DD')))=nvl(msi.ENGINEERING_DATE,TO_DATE('1000/01/01','YYYY/MM/DD'))
                        and decode(A_NEGATIVE_MEASUREMENT_ERROR,X_TRUE,nvl(cr.NEGATIVE_MEASUREMENT_ERROR,-1),nvl(msi.NEGATIVE_MEASUREMENT_ERROR,-1))=nvl(msi.NEGATIVE_MEASUREMENT_ERROR,-1)
                        and decode(A_ENGINEERING_ECN_CODE,X_TRUE,nvl(cr.ENGINEERING_ECN_CODE,-1),nvl(msi.ENGINEERING_ECN_CODE,-1))=nvl(msi.ENGINEERING_ECN_CODE,-1)
                        and decode(A_ENGINEERING_ITEM_ID,X_TRUE,nvl(cr.ENGINEERING_ITEM_ID,-1),nvl(msi.ENGINEERING_ITEM_ID,-1))=nvl(msi.ENGINEERING_ITEM_ID,-1)
                        and decode(A_SERVICE_STARTING_DELAY,X_TRUE,nvl(cr.SERVICE_STARTING_DELAY,-1),nvl(msi.SERVICE_STARTING_DELAY,-1))=nvl(msi.SERVICE_STARTING_DELAY,-1)
                        and decode(A_SERVICEABLE_COMPONENT_FLAG,X_TRUE,nvl(cr.SERVICEABLE_COMPONENT_FLAG,-1),nvl(msi.SERVICEABLE_COMPONENT_FLAG,-1))=nvl(msi.SERVICEABLE_COMPONENT_FLAG,-1);

                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7A',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7A',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7A */


                begin /* MASTER_CHILD_7B */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_SERVICEABLE_PRODUCT_FLAG,X_TRUE,nvl(cr.SERVICEABLE_PRODUCT_FLAG,-1),nvl(msi.SERVICEABLE_PRODUCT_FLAG,-1))=nvl(msi.SERVICEABLE_PRODUCT_FLAG,-1)
                        and decode(A_BASE_WARRANTY_SERVICE_ID,X_TRUE,nvl(cr.BASE_WARRANTY_SERVICE_ID,-1),nvl(msi.BASE_WARRANTY_SERVICE_ID,-1))=nvl(msi.BASE_WARRANTY_SERVICE_ID,-1)
                        and decode(A_PAYMENT_TERMS_ID,X_TRUE,nvl(cr.PAYMENT_TERMS_ID,-1),nvl(msi.PAYMENT_TERMS_ID,-1))=nvl(msi.PAYMENT_TERMS_ID,-1)
                        and decode(A_PREVENTIVE_MAINTENANCE_FLAG,X_TRUE,nvl(cr.PREVENTIVE_MAINTENANCE_FLAG,-1),nvl(msi.PREVENTIVE_MAINTENANCE_FLAG,-1))=nvl(msi.PREVENTIVE_MAINTENANCE_FLAG,-1)
                        and decode(A_PRIMARY_SPECIALIST_ID,X_TRUE,nvl(cr.PRIMARY_SPECIALIST_ID,-1),nvl(msi.PRIMARY_SPECIALIST_ID,-1))=nvl(msi.PRIMARY_SPECIALIST_ID,-1)
                        and decode(A_SECONDARY_SPECIALIST_ID,X_TRUE,nvl(cr.SECONDARY_SPECIALIST_ID,-1),nvl(msi.SECONDARY_SPECIALIST_ID,-1))=nvl(msi.SECONDARY_SPECIALIST_ID,-1)
                        and decode(A_SERVICEABLE_ITEM_CLASS_ID,X_TRUE,nvl(cr.SERVICEABLE_ITEM_CLASS_ID,-1),nvl(msi.SERVICEABLE_ITEM_CLASS_ID,-1))=nvl(msi.SERVICEABLE_ITEM_CLASS_ID,-1);

                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7B',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7B',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7B */

                begin /* MASTER_CHILD_7C */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
--Bug 4496767           and decode(A_TIME_BILLABLE_FLAG,X_TRUE,nvl(cr.TIME_BILLABLE_FLAG,-1),nvl(msi.TIME_BILLABLE_FLAG,-1))=nvl(msi.TIME_BILLABLE_FLAG,-1)
                        and decode(A_MATERIAL_BILLABLE_FLAG,X_TRUE,nvl(cr.MATERIAL_BILLABLE_FLAG,-1),nvl(msi.MATERIAL_BILLABLE_FLAG,-1))=nvl(msi.MATERIAL_BILLABLE_FLAG,-1)
--Bug 4496767           and decode(A_EXPENSE_BILLABLE_FLAG,X_TRUE,nvl(cr.EXPENSE_BILLABLE_FLAG,-1),nvl(msi.EXPENSE_BILLABLE_FLAG,-1))=nvl(msi.EXPENSE_BILLABLE_FLAG,-1)
                        and decode(A_PRORATE_SERVICE_FLAG,X_TRUE,nvl(cr.PRORATE_SERVICE_FLAG,-1),nvl(msi.PRORATE_SERVICE_FLAG,-1))=nvl(msi.PRORATE_SERVICE_FLAG,-1)
                        and decode(A_COVERAGE_SCHEDULE_ID,X_TRUE,nvl(cr.COVERAGE_SCHEDULE_ID,-1),nvl(msi.COVERAGE_SCHEDULE_ID,-1))=nvl(msi.COVERAGE_SCHEDULE_ID,-1)
                        and decode(A_SERVICE_DURATION_PERIOD_CODE,X_TRUE,nvl(cr.SERVICE_DURATION_PERIOD_CODE,-1),nvl(msi.SERVICE_DURATION_PERIOD_CODE,-1))=nvl(msi.SERVICE_DURATION_PERIOD_CODE,-1)
                        and decode(A_SERVICE_DURATION,X_TRUE,nvl(cr.SERVICE_DURATION,-1),nvl(msi.SERVICE_DURATION,-1))=nvl(msi.SERVICE_DURATION,-1)
                        and decode(A_WARRANTY_VENDOR_ID,X_TRUE,nvl(cr.WARRANTY_VENDOR_ID,-1),nvl(msi.WARRANTY_VENDOR_ID,-1))=nvl(msi.WARRANTY_VENDOR_ID,-1);

                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7C',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7C',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7C */

                begin /* MASTER_CHILD_7D */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_MAX_WARRANTY_AMOUNT,X_TRUE,nvl(cr.MAX_WARRANTY_AMOUNT,-1),nvl(msi.MAX_WARRANTY_AMOUNT,-1))=nvl(msi.MAX_WARRANTY_AMOUNT,-1)
                        and decode(A_RESPONSE_TIME_PERIOD_CODE,X_TRUE,nvl(cr.RESPONSE_TIME_PERIOD_CODE,-1),nvl(msi.RESPONSE_TIME_PERIOD_CODE,-1))=nvl(msi.RESPONSE_TIME_PERIOD_CODE,-1)
                        and decode(A_RESPONSE_TIME_VALUE,X_TRUE,nvl(cr.RESPONSE_TIME_VALUE,-1),nvl(msi.RESPONSE_TIME_VALUE,-1))=nvl(msi.RESPONSE_TIME_VALUE,-1)
                        and decode(A_NEW_REVISION_CODE,X_TRUE,nvl(cr.NEW_REVISION_CODE,-1),nvl(msi.NEW_REVISION_CODE,-1))=nvl(msi.NEW_REVISION_CODE,-1)
                        and decode(A_INVOICEABLE_ITEM_FLAG,X_TRUE,nvl(cr.INVOICEABLE_ITEM_FLAG,-1),nvl(msi.INVOICEABLE_ITEM_FLAG,-1))=nvl(msi.INVOICEABLE_ITEM_FLAG,-1)
                        and decode(A_TAX_CODE,X_TRUE,nvl(cr.TAX_CODE,-1),nvl(msi.TAX_CODE,-1))=nvl(msi.TAX_CODE,-1)
                        and decode(A_INVOICE_ENABLED_FLAG,X_TRUE,nvl(cr.INVOICE_ENABLED_FLAG,-1),nvl(msi.INVOICE_ENABLED_FLAG,-1))=nvl(msi.INVOICE_ENABLED_FLAG,-1)
                        and decode(A_MUST_USE_APPROVED_VENDOR_F,X_TRUE,nvl(cr.MUST_USE_APPROVED_VENDOR_FLAG,-1),nvl(msi.MUST_USE_APPROVED_VENDOR_FLAG,-1))=nvl(msi.MUST_USE_APPROVED_VENDOR_FLAG,-1);

                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7D',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7D',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7D */


                begin /* MASTER_CHILD_7E */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_RELEASE_TIME_FENCE_CODE,X_TRUE,nvl(cr.RELEASE_TIME_FENCE_CODE,-1),nvl(msi.RELEASE_TIME_FENCE_CODE,-1))=nvl(msi.RELEASE_TIME_FENCE_CODE,-1)
                        and decode(A_RELEASE_TIME_FENCE_DAYS,X_TRUE,nvl(cr.RELEASE_TIME_FENCE_DAYS,-1),nvl(msi.RELEASE_TIME_FENCE_DAYS,-1))=nvl(msi.RELEASE_TIME_FENCE_DAYS,-1)
                        and decode(A_CONTAINER_ITEM_FLAG,X_TRUE,nvl(cr.CONTAINER_ITEM_FLAG,-1),nvl(msi.CONTAINER_ITEM_FLAG,-1))=nvl(msi.CONTAINER_ITEM_FLAG,-1)
                        and decode(A_CONTAINER_TYPE_CODE,X_TRUE,nvl(cr.CONTAINER_TYPE_CODE,-1),nvl(msi.CONTAINER_TYPE_CODE,-1))=nvl(msi.CONTAINER_TYPE_CODE,-1)
                        and decode(A_INTERNAL_VOLUME,X_TRUE,nvl(cr.INTERNAL_VOLUME,-1),nvl(msi.INTERNAL_VOLUME,-1))=nvl(msi.INTERNAL_VOLUME,-1)
                        and decode(A_MAXIMUM_LOAD_WEIGHT,X_TRUE,nvl(cr.MAXIMUM_LOAD_WEIGHT,-1),nvl(msi.MAXIMUM_LOAD_WEIGHT,-1))=nvl(msi.MAXIMUM_LOAD_WEIGHT,-1)
                        and decode(A_MINIMUM_FILL_PERCENT,X_TRUE,nvl(cr.MINIMUM_FILL_PERCENT,-1),nvl(msi.MINIMUM_FILL_PERCENT,-1))=nvl(msi.MINIMUM_FILL_PERCENT,-1)
                        and decode(A_VEHICLE_ITEM_FLAG,X_TRUE,nvl(cr.VEHICLE_ITEM_FLAG,-1),nvl(msi.VEHICLE_ITEM_FLAG,-1))=nvl(msi.VEHICLE_ITEM_FLAG,-1);

                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7E',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7E',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7E */
-- Added for 11.5.10
                begin /* MASTER_CHILD_7F */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_TRACKING_QUANTITY_IND,X_TRUE,nvl(cr.TRACKING_QUANTITY_IND,-1),nvl(msi.TRACKING_QUANTITY_IND,-1))=nvl(msi.TRACKING_QUANTITY_IND,-1)
                        and decode(A_ONT_PRICING_QTY_SOURCE,X_TRUE,nvl(cr.ONT_PRICING_QTY_SOURCE,-1),nvl(msi.ONT_PRICING_QTY_SOURCE,-1))=nvl(msi.ONT_PRICING_QTY_SOURCE,-1)
                        and decode(A_SECONDARY_DEFAULT_IND,X_TRUE,nvl(cr.SECONDARY_DEFAULT_IND,-1),nvl(msi.SECONDARY_DEFAULT_IND,-1))=nvl(msi.SECONDARY_DEFAULT_IND,-1);
                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7F',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7F',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7F */

                begin /* MASTER_CHILD_7G */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_CONFIG_ORGS,X_TRUE,nvl(cr.CONFIG_ORGS,-1),nvl(msi.CONFIG_ORGS,-1))=nvl(msi.CONFIG_ORGS,-1)
                        and decode(A_CONFIG_MATCH,X_TRUE,nvl(cr.CONFIG_MATCH,-1),nvl(msi.CONFIG_MATCH,-1))=nvl(msi.CONFIG_MATCH,-1);
                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7G',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7G',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7G */

                begin /* MASTER_CHILD_7H */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                and decode(A_SO_AUTHORIZATION_FLAG,X_TRUE,nvl(cr.SO_AUTHORIZATION_FLAG,-1),nvl(msi.SO_AUTHORIZATION_FLAG,-1))=nvl(msi.SO_AUTHORIZATION_FLAG,-1)
                        and decode(A_VMI_MINIMUM_UNITS,X_TRUE,nvl(cr.VMI_MINIMUM_UNITS,-1),nvl(msi.VMI_MINIMUM_UNITS,-1))=nvl(msi.VMI_MINIMUM_UNITS,-1)
                        and decode(A_VMI_MINIMUM_DAYS,X_TRUE,nvl(cr.VMI_MINIMUM_DAYS,-1),nvl(msi.VMI_MINIMUM_DAYS,-1))= nvl(msi.VMI_MINIMUM_DAYS,-1)
                        and decode(A_VMI_MAXIMUM_DAYS,X_TRUE,nvl(cr.VMI_MAXIMUM_DAYS,-1),nvl(msi.VMI_MAXIMUM_DAYS,-1))= nvl(msi.VMI_MAXIMUM_DAYS,-1)
                        and decode(A_VMI_MAXIMUM_UNITS,X_TRUE,nvl(cr.VMI_MAXIMUM_UNITS,-1),nvl(msi.VMI_MAXIMUM_UNITS,-1))= nvl(msi.VMI_MAXIMUM_UNITS,-1)
                        and decode(A_VMI_FIXED_ORDER_QUANTITY,X_TRUE,nvl(cr.VMI_FIXED_ORDER_QUANTITY,-1),nvl(msi.VMI_FIXED_ORDER_QUANTITY,-1))= nvl(msi.VMI_FIXED_ORDER_QUANTITY,-1)
                        and decode(A_CONSIGNED_FLAG,X_TRUE,nvl(cr.CONSIGNED_FLAG,-1),nvl(msi.CONSIGNED_FLAG,-1))= nvl(msi.CONSIGNED_FLAG,-1)
                        and decode(A_ASN_AUTOEXPIRE_FLAG,X_TRUE,nvl(cr.ASN_AUTOEXPIRE_FLAG,-1),nvl(msi.ASN_AUTOEXPIRE_FLAG,-1))= nvl(msi.ASN_AUTOEXPIRE_FLAG,-1)
                        and decode(A_FORECAST_HORIZON,X_TRUE,nvl(cr.FORECAST_HORIZON,-1),nvl(msi.FORECAST_HORIZON,-1))= nvl(msi.FORECAST_HORIZON,-1)
                        and decode(A_EXCLUDE_FROM_BUDGET_FLAG,X_TRUE,nvl(cr.EXCLUDE_FROM_BUDGET_FLAG,-1),nvl(msi.EXCLUDE_FROM_BUDGET_FLAG,-1))= nvl(msi.EXCLUDE_FROM_BUDGET_FLAG,-1)
                        and decode(A_DAYS_TGT_INV_SUPPLY,X_TRUE,nvl(cr.DAYS_TGT_INV_SUPPLY,-1),nvl(msi.DAYS_TGT_INV_SUPPLY,-1))= nvl(msi.DAYS_TGT_INV_SUPPLY,-1)
                        and decode(A_DAYS_TGT_INV_WINDOW,X_TRUE,nvl(cr.DAYS_TGT_INV_WINDOW,-1),nvl(msi.DAYS_TGT_INV_WINDOW,-1))= nvl(msi.DAYS_TGT_INV_WINDOW,-1)
                        and decode(A_DAYS_MAX_INV_WINDOW,X_TRUE,nvl(cr.DAYS_MAX_INV_WINDOW,-1),nvl(msi.DAYS_MAX_INV_WINDOW,-1))= nvl(msi.DAYS_MAX_INV_WINDOW,-1)
                        and decode(A_DAYS_MAX_INV_SUPPLY,X_TRUE,nvl(cr.DAYS_MAX_INV_SUPPLY,-1),nvl(msi.DAYS_MAX_INV_SUPPLY,-1))= nvl(msi.DAYS_MAX_INV_SUPPLY,-1)
                        and decode(A_DRP_PLANNED_FLAG,X_TRUE,nvl(cr.DRP_PLANNED_FLAG,-1),nvl(msi.DRP_PLANNED_FLAG,-1))= nvl(msi.DRP_PLANNED_FLAG,-1)
                        and decode(A_CRITICAL_COMPONENT_FLAG,X_TRUE,nvl(cr.CRITICAL_COMPONENT_FLAG,-1),nvl(msi.CRITICAL_COMPONENT_FLAG,-1))= nvl(msi.CRITICAL_COMPONENT_FLAG,-1)
                        and decode(A_CONTINOUS_TRANSFER,X_TRUE,nvl(cr.CONTINOUS_TRANSFER,-1),nvl(msi.CONTINOUS_TRANSFER,-1))=nvl(msi.CONTINOUS_TRANSFER,-1)
                        and decode(A_VMI_FORECAST_TYPE,X_TRUE,nvl(cr.VMI_FORECAST_TYPE,-1),nvl(msi.VMI_FORECAST_TYPE,-1))=nvl(msi.VMI_FORECAST_TYPE,-1)
                        and decode(A_CONVERGENCE,X_TRUE,nvl(cr.CONVERGENCE,-1),nvl(msi.CONVERGENCE,-1))=nvl(msi.CONVERGENCE,-1)
                        and decode(A_DIVERGENCE,X_TRUE,nvl(cr.DIVERGENCE,-1),nvl(msi.DIVERGENCE,-1))=nvl(msi.DIVERGENCE,-1) ;
                exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7G',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7H',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7H */

                /* Start Bug 3713912 */
                begin /* MASTER_CHILD_7I */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_LOT_DIVISIBLE_FLAG            ,X_TRUE,nvl(cr.LOT_DIVISIBLE_FLAG            ,-1),nvl(msi.LOT_DIVISIBLE_FLAG            ,-1))= nvl(msi.LOT_DIVISIBLE_FLAG,-1)
                        and decode(A_GRADE_CONTROL_FLAG            ,X_TRUE,nvl(cr.GRADE_CONTROL_FLAG            ,-1),nvl(msi.GRADE_CONTROL_FLAG            ,-1))= nvl(msi.GRADE_CONTROL_FLAG,-1)
                        and decode(A_DEFAULT_GRADE                 ,X_TRUE,nvl(cr.DEFAULT_GRADE                 ,-1),nvl(msi.DEFAULT_GRADE                 ,-1))= nvl(msi.DEFAULT_GRADE,-1)
                        and decode(A_CHILD_LOT_FLAG                ,X_TRUE,nvl(cr.CHILD_LOT_FLAG                ,-1),nvl(msi.CHILD_LOT_FLAG                ,-1))= nvl(msi.CHILD_LOT_FLAG,-1)
                        and decode(A_PARENT_CHILD_GENERATION_FLAG  ,X_TRUE,nvl(cr.PARENT_CHILD_GENERATION_FLAG  ,-1),nvl(msi.PARENT_CHILD_GENERATION_FLAG  ,-1))= nvl(msi.PARENT_CHILD_GENERATION_FLAG,-1)
                        and decode(A_CHILD_LOT_PREFIX              ,X_TRUE,nvl(cr.CHILD_LOT_PREFIX              ,-1),nvl(msi.CHILD_LOT_PREFIX              ,-1))= nvl(msi.CHILD_LOT_PREFIX,-1)
                        and decode(A_CHILD_LOT_STARTING_NUMBER     ,X_TRUE,nvl(cr.CHILD_LOT_STARTING_NUMBER     ,-1),nvl(msi.CHILD_LOT_STARTING_NUMBER     ,-1))= nvl(msi.CHILD_LOT_STARTING_NUMBER,-1)
                        and decode(A_CHILD_LOT_VALIDATION_FLAG     ,X_TRUE,nvl(cr.CHILD_LOT_VALIDATION_FLAG     ,-1),nvl(msi.CHILD_LOT_VALIDATION_FLAG     ,-1))= nvl(msi.CHILD_LOT_VALIDATION_FLAG,-1)
                        and decode(A_COPY_LOT_ATTRIBUTE_FLAG       ,X_TRUE,nvl(cr.COPY_LOT_ATTRIBUTE_FLAG       ,-1),nvl(msi.COPY_LOT_ATTRIBUTE_FLAG       ,-1))= nvl(msi.COPY_LOT_ATTRIBUTE_FLAG,-1)
                        and decode(A_RECIPE_ENABLED_FLAG           ,X_TRUE,nvl(cr.RECIPE_ENABLED_FLAG           ,-1),nvl(msi.RECIPE_ENABLED_FLAG           ,-1))= nvl(msi.RECIPE_ENABLED_FLAG,-1)
                        and decode(A_PROCESS_QUALITY_ENABLED_FLAG  ,X_TRUE,nvl(cr.PROCESS_QUALITY_ENABLED_FLAG  ,-1),nvl(msi.PROCESS_QUALITY_ENABLED_FLAG  ,-1))= nvl(msi.PROCESS_QUALITY_ENABLED_FLAG,-1)
                        and decode(A_PROCESS_EXEC_ENABLED_FLAG     ,X_TRUE,nvl(cr.PROCESS_EXECUTION_ENABLED_FLAG,-1),nvl(msi.PROCESS_EXECUTION_ENABLED_FLAG,-1))= nvl(msi.PROCESS_EXECUTION_ENABLED_FLAG,-1);
                exception
                when NO_DATA_FOUND then
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7I',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7I',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7I */


                /* Start Bug 3713912 */
                begin /* MASTER_CHILD_7J */

                        select inventory_item_id into msicount
                        from mtl_system_items msi
                        where msi.inventory_item_id = cr.III
                        and   msi.organization_id = cr.MORGID
                        and decode(A_PROCESS_COSTING_ENABLED_FLAG  ,X_TRUE,nvl(cr.PROCESS_COSTING_ENABLED_FLAG,-1),nvl(msi.PROCESS_COSTING_ENABLED_FLAG,-1))= nvl(msi.PROCESS_COSTING_ENABLED_FLAG,-1)
                        and decode(A_HAZARDOUS_MATERIAL_FLAG       ,X_TRUE,nvl(cr.HAZARDOUS_MATERIAL_FLAG,-1),nvl(msi.HAZARDOUS_MATERIAL_FLAG,-1))= nvl(msi.HAZARDOUS_MATERIAL_FLAG,-1)
                        and decode(A_CAS_NUMBER                    ,X_TRUE,nvl(cr.CAS_NUMBER,-1),nvl(msi.CAS_NUMBER,-1))= nvl(msi.CAS_NUMBER,-1)
                        and decode(A_RETEST_INTERVAL               ,X_TRUE,nvl(cr.RETEST_INTERVAL,-1),nvl(msi.RETEST_INTERVAL,-1))= nvl(msi.RETEST_INTERVAL,-1)
                        and decode(A_EXPIRATION_ACTION_INTERVAL    ,X_TRUE,nvl(cr.EXPIRATION_ACTION_INTERVAL,-1),nvl(msi.EXPIRATION_ACTION_INTERVAL,-1))= nvl(msi.EXPIRATION_ACTION_INTERVAL,-1)
                        and decode(A_EXPIRATION_ACTION_CODE        ,X_TRUE,nvl(cr.EXPIRATION_ACTION_CODE,-1),nvl(msi.EXPIRATION_ACTION_CODE,-1))= nvl(msi.EXPIRATION_ACTION_CODE,-1)
                        and decode(A_MATURITY_DAYS                 ,X_TRUE,nvl(cr.MATURITY_DAYS,-1),nvl(msi.MATURITY_DAYS,-1))= nvl(msi.MATURITY_DAYS,-1)
                        and decode(A_HOLD_DAYS                     ,X_TRUE,nvl(cr.HOLD_DAYS,-1),nvl(msi.HOLD_DAYS,-1))= nvl(msi.HOLD_DAYS,-1)   ;
                exception
                when NO_DATA_FOUND then
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.ORGID,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MASTER_CHILD_7J',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MASTER_CHILD_7J',
                                err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End if;
                                update mtl_system_items_interface msii
                                set process_flag = 3
                                where msii.transaction_id = cr.transaction_id;

                end;  /* MASTER_CHILD_7J */
                /* End Bug 3713912 */

        end loop;

        return(0);
exception
        when LOGGING_ERR then
                return(dumm_status);
        when VALIDATE_ERR then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                trans_id,
                                err_text,
                                'MASTER_CHILD_7',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
                return(status);
        when OTHERS then
                err_text := substr('INVPVALI.validate_item_org7' || SQLERRM ,1 , 240);
                return(SQLCODE);

END validate_item_org7;


END INVPVLM3;

/
