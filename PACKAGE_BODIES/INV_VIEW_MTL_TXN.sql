--------------------------------------------------------
--  DDL for Package Body INV_VIEW_MTL_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_VIEW_MTL_TXN" AS
/*$Header: INVVTXNB.pls 120.0.12010000.2 2009/04/09 09:18:45 skommine ship $*/

/*
** --------------------------------------------------------------------------
** Procedure :Get_Decription
** Decription: This procedure accepts thedentofiers and returns the
**             description for the identifiers. The following columns
**             from mtl_material_transactions are passed as input for
**             this procedure
**
**   TRANSACTION_TYPE_ID
**   TRANSACTION_ACTION_ID
**   COSTED_FLAG
**   PM_COST_COLLECTED
**   PM_COST_COLLECTOR_GROUP_ID
**   TRANSACTION_SOURCE_TYPE_ID
**   REASON_ID
**   DEPARTMENT_ID
**   TRANSFER_ORGANIZATION_ID
**   LPN_ID
**   CONTENT_LPN_ID
**   TRANSFER_LPN_ID
**   COST_GROUP_ID
**   TRANSFER_COST_GROUP_ID
**   INV_ADV_INSTALLED
**   PUT_AWAY_STRATEGY_ID
**   PUT_AWAY_RULE_ID
**   PICK_STRATEGY_ID
**   PICK_RULE_ID
**   ORGANIZATION_ID
**   TRANSFER_OWNING_TP_TYPE
**   XFR_OWNING_ORGANIZATION_ID
**
** The following are the output columns for the procedure:
**  X_RETURN_STATUS               :Return Status indicating success,
**                                 error, unexpected error for the procedure
**  X_MSG_DATA                    :if the number of messages in message list
**                                  is 1, contains message text
**  X_MSG_COUNT                   :number of messages in message list
**  X_TRANSACTION_TYPE_NAME       : Description for TRANSACTION_TYPE_ID
**  X_TRANSACTION_ACTION          : Description for TRANSACTION_ACTION_ID
**  X_COSTED_FLAG_1               : Description for COSTED_FLAG
**  X_COSTED_LOOKUP_CODE          : Description for COSTED_LOOKUP_CODE
**  X_PM_COST_COLLECTED_1         : Description for PM_COST_COLLECTED
**  X_PM_COST_COLLECTED_LK_CODE   : Description for COSTED_LOOKUP_CODE
**  X_TRANSACTION_SOURCE_TYPE_NAME: Description for TRANSACTION_SOURCE_TYPE_ID
**  X_TRANSACTION_SOURCE_NAME_DB  : Description for TRANSACTION_SOURCE_TYPE_ID
**  X_REASON_NAME                 : Description for REASON_ID
**  X_DEPARTMENT_CODE             : Description for DEPARTMENT_ID
**  X_TRANSFER_ORGANIZATION_NAME  : Description for TRANSFER_ORGANIZATION_ID
**  X_TRANSFER_LPN                : Description for TRANSFER_LPN_ID
**  X_CONTENT_LPN                 : Description for CONTENT_LPN_ID
**  X_LPN                         : Description for LPN_ID
**  X_COST_GROUP_NAME             : Description for COST_GROUP_ID
**  X_TRANSFER_COST_GROUP_NAME    : Description for TRANSFER_COST_GROUP_ID
**  X_PUT_AWAY_STRATEGY_NAME      : Description for PUT_AWAY_STRATEGY_ID
**  X_PUT_AWAY_RULE_NAME          : Description for PUT_AWAY_RULE_ID
**  X_PICK_STRATEGY_NAME          : Description for PICK_STRATEGY_ID
**  X_PICK_RULE_NAME              : Description for PICK_RULE_ID
**  X_ORGANIZATION_CODE           : Description for ORGANIZATION_ID
**  X_OPERATIN_UNIT               : Operating Unit for the ORGANIZATION_ID
**  X_XFR_OWNING_ORGANIZATION_NAME: Description for XFR_OWNING_ORGANIZATION_ID
*/
PROCEDURE GET_DESCRIPTION(
           X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
          ,X_MSG_DATA                       OUT NOCOPY VARCHAR2
          ,X_MSG_COUNT                      OUT NOCOPY NUMBER
          ,X_TRANSACTION_TYPE_NAME          OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_ACTION             OUT NOCOPY VARCHAR2
          ,X_COSTED_FLAG_1                  OUT NOCOPY VARCHAR2
          ,X_COSTED_LOOKUP_CODE             OUT NOCOPY VARCHAR2
          ,X_PM_COST_COLLECTED_1            OUT NOCOPY VARCHAR2
          ,X_PM_COST_COLLECTED_LK_CODE      OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_SOURCE_TYPE_NAME   OUT NOCOPY VARCHAR2
          ,X_TRANSACTION_SOURCE_NAME_DB     OUT NOCOPY VARCHAR2
          ,X_REASON_NAME                    OUT NOCOPY VARCHAR2
          ,X_DEPARTMENT_CODE                OUT NOCOPY VARCHAR2
          ,X_TRANSFER_ORGANIZATION_NAME     OUT NOCOPY VARCHAR2
          ,X_TRANSFER_LPN                   OUT NOCOPY VARCHAR2
          ,X_CONTENT_LPN                    OUT NOCOPY VARCHAR2
          ,X_LPN                            OUT NOCOPY VARCHAR2
          ,X_COST_GROUP_NAME                OUT NOCOPY VARCHAR2
          ,X_TRANSFER_COST_GROUP_NAME       OUT NOCOPY VARCHAR2
          ,X_put_away_strategy_name         OUT NOCOPY VARCHAR2
          ,X_put_away_rule_name             OUT NOCOPY VARCHAR2
          ,X_PICK_STRATEGY_NAME             OUT NOCOPY VARCHAR2
          ,X_PICK_RULE_NAME                 OUT NOCOPY VARCHAR2
          ,x_owning_organization_name       OUT NOCOPY VARCHAR2
          ,x_supplier                       OUT NOCOPY VARCHAR2
          ,x_supplier_site_name             OUT NOCOPY varchar2
          ,X_ORGANIZATION_CODE              OUT NOCOPY VARCHAR2
          ,X_OPERATING_UNIT                 OUT NOCOPY VARCHAR2
          ,X_XFR_OWNING_ORGANIZATION_NAME   OUT NOCOPY VARCHAR2
          ,p_TRANSACTION_TYPE_ID             IN NUMBER
          ,p_TRANSACTION_ACTION_ID           IN NUMBER
          ,p_COSTED_FLAG                     IN VARCHAR2
          ,p_PM_COST_COLLECTED               IN VARCHAR2
          ,P_PM_COST_COLLECTOR_GROUP_ID      IN VARCHAR2
          ,p_TRANSACTION_SOURCE_TYPE_ID      IN NUMBER
          ,P_REASON_ID                       IN NUMBER
          ,p_DEPARTMENT_ID                   IN NUMBER
          ,p_TRANSFER_ORGANIZATION_ID        IN NUMBER
          ,p_LPN_ID                          IN NUMBER
          ,p_content_lpn_id                  IN NUMBER
          ,p_transfer_lpn_id                 IN NUMBER
          ,p_COST_GROUP_ID                   IN NUMBER
          ,p_TRANSFER_COST_GROUP_ID          IN NUMBER
          ,p_INV_ADV_INSTALLED               IN VARCHAR2
          ,p_put_away_strategy_id            IN NUMBER
          ,p_put_away_rule_id                IN NUMBER
          ,p_pick_strategy_id                IN NUMBER
          ,p_pick_rule_id                    IN NUMBER
          ,p_owning_organization_id          IN NUMBER
          ,p_planning_tp_type                IN NUMBER
          ,p_owning_tp_type                  IN NUMBER
          ,p_planning_organization_id        IN number
          ,p_organization_id                 IN NUMBER DEFAULT NULL
          ,p_transfer_owning_tp_type         IN NUMBER
          ,p_xfr_owning_organization_id      IN NUMBER
          ) IS
BEGIN

   SAVEPOINT get_desc;

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

IF (p_owning_tp_type IS NULL OR p_owning_tp_type=2) THEN
    BEGIN
       SELECT (MP.organization_code||'-'||HAOU.name)
         INTO x_owning_organization_name
         FROM HR_ALL_ORGANIZATION_UNITS HAOU
            , MTL_PARAMETERS MP
         WHERE HAOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
         AND   HAOU.ORGANIZATION_ID = p_owning_organization_id;
   EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;
END IF;

IF (p_owning_tp_type=1) THEN
    BEGIN
       SELECT (pov.vendor_name||'-'||povs.vendor_site_code)
         INTO x_owning_organization_name
         FROM po_vendor_sites_all povs, po_vendors POV
         WHERE povs.vendor_site_id = p_owning_organization_id
         AND povs.vendor_id = pov.vendor_id;
    EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;
END IF;

  -- no need to get transfer owning org when tp type is NULL
  -- only get transfer owning org for transfer to regular
  -- transaction type
  IF NOT (p_transfer_owning_tp_type=2 AND
      p_transaction_source_type_id = 1 AND
      p_transaction_action_id = 6) THEN
    BEGIN
       SELECT (MP.organization_code||'-'||HAOU.name)
         INTO x_xfr_owning_organization_name
         FROM HR_ALL_ORGANIZATION_UNITS HAOU
            , MTL_PARAMETERS MP
         WHERE HAOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
         AND   HAOU.ORGANIZATION_ID = p_xfr_owning_organization_id;
   EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;
  END IF;

  IF (p_transfer_owning_tp_type=1) THEN
    BEGIN
       SELECT (pov.vendor_name||'-'||povs.vendor_site_code)
         INTO x_xfr_owning_organization_name
         FROM po_vendor_sites_all povs, po_vendors POV
         WHERE povs.vendor_site_id = p_xfr_owning_organization_id
         AND povs.vendor_id = pov.vendor_id;
    EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
  END IF;

IF (p_PLANNING_TP_TYPE IS NULL OR p_planning_tp_type=2) THEN
    BEGIN
       SELECT (MP.organization_code||'-'||HAOU.name), NULL
         INTO x_supplier_site_name, x_supplier
         FROM HR_ALL_ORGANIZATION_UNITS HAOU
            , MTL_PARAMETERS MP
         WHERE HAOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
         AND HAOU.ORGANIZATION_ID = p_planning_organization_id;
   EXCEPTION
       WHEN OTHERS THEN
          NULL;

    END;
END IF;

IF (p_planning_tp_type=1) THEN
    BEGIN
       SELECT (pov.vendor_name||'-'||povs.vendor_site_code),pov.vendor_name
         INTO x_supplier_site_name, x_supplier
         FROM po_vendor_sites_all povs, po_vendors POV
         WHERE povs.vendor_site_id = p_planning_organization_id
         AND povs.vendor_id = pov.vendor_id;

    EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;
END IF;

  IF p_TRANSACTION_TYPE_ID IS NOT NULL THEN
    BEGIN
      SELECT TRANSACTION_TYPE_NAME
       INTO x_TRANSACTION_TYPE_NAME
       FROM MTL_TRANSACTION_TYPES
       WHERE TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID;
     EXCEPTION
       WHEN OTHERS THEN
        NULL;
     END;
   END IF;

   IF p_TRANSACTION_ACTION_ID IS NOT NULL THEN
     BEGIN
        SELECT MEANING
        INTO x_TRANSACTION_ACTION
        FROM  MFG_LOOKUPS
        WHERE LOOKUP_TYPE    ='MTL_TRANSACTION_ACTION'
         AND LOOKUP_CODE =p_TRANSACTION_ACTION_ID;
      EXCEPTION
        WHEN OTHERS THEN
         NULL;
      END;
    END IF;

     BEGIN
         SELECT MEANING,LOOKUP_CODE
         INTO x_COSTED_FLAG_1,
              x_COSTED_LOOKUP_CODE
         FROM  MFG_LOOKUPS
         WHERE LOOKUP_TYPE ='INV_YES_NO_ERROR'
           AND LOOKUP_CODE =DECODE(p_COSTED_FLAG,NULL,1,'Y',1,'N',2,'E',3);
     EXCEPTION
        WHEN OTHERS THEN
        null;
     END;
      BEGIN
         SELECT MEANING,LOOKUP_CODE
         INTO x_PM_COST_COLLECTED_1,
              x_PM_COST_COLLECTED_LK_CODE
         FROM  MFG_LOOKUPS
         WHERE LOOKUP_TYPE ='INV_YES_NO_ERROR_NA'
           AND LOOKUP_CODE =DECODE (p_PM_COST_COLLECTED, NULL,
                                            DECODE(p_PM_COST_COLLECTOR_GROUP_ID,
                                                   NULL,4,1),
                                                    'Y', 1,
                                                    'N', 2,
                                                    'E', 3
                                    );
       EXCEPTION
           WHEN OTHERS THEN
           null;
       END;

     IF p_TRANSACTION_SOURCE_TYPE_ID IS NOT NULL THEN
        BEGIN
           SELECT TRANSACTION_SOURCE_TYPE_NAME,
                 TRANSACTION_SOURCE_TYPE_NAME
           INTO x_TRANSACTION_SOURCE_TYPE_NAME,
                x_TRANSACTION_SOURCE_NAME_DB
           FROM  mtl_txn_source_types
           WHERE TRANSACTION_SOURCE_TYPE_ID =p_TRANSACTION_SOURCE_TYPE_ID  ;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
           NULL;
         END;
      END IF;

      IF p_REASON_ID IS NOT NULL THEN
        BEGIN
          SELECT REASON_NAME
          INTO x_REASON_NAME
          FROM MTL_TRANSACTION_REASONS
          WHERE REASON_ID =p_REASON_ID;
        EXCEPTION
          WHEN OTHERS THEN
          NULL;
        END;
       END IF;

       IF p_DEPARTMENT_ID IS NOT NULL THEN
         BEGIN
            SELECT DEPARTMENT_CODE
            INTO x_DEPARTMENT_CODE
            FROM BOM_DEPARTMENTS
            WHERE DEPARTMENT_ID =p_DEPARTMENT_ID;
          EXCEPTION
            WHEN OTHERS THEN
            NULL;
          END;
        END IF;


        IF p_TRANSFER_ORGANIZATION_ID IS NOT NULL THEN
           BEGIN
             SELECT DISTINCT ORGANIZATION_CODE
             INTO x_TRANSFER_ORGANIZATION_NAME
             FROM MTL_PARAMETERS
             WHERE ORGANIZATION_ID = p_TRANSFER_ORGANIZATION_ID;
           EXCEPTION
             WHEN OTHERS THEN
             NULL;
           END;
	END IF;


 IF inv_control.get_current_release_level >= inv_release.GET_J_RELEASE_LEVEL then
	If P_ORGANIZATION_ID IS NOT NULL THEN
       BEGIN

           SELECT OOD. ORGANIZATION_NAME, HOU.NAME
           INTO X_ORGANIZATION_CODE , X_OPERATING_UNIT
           FROM ORG_ORGANIZATION_DEFINITIONS OOD, HR_OPERATING_UNITS HOU
           WHERE OOD.ORGANIZATION_ID = P_ORGANIZATION_ID AND
           OOD.OPERATING_UNIT = HOU.ORGANIZATION_ID;

	  EXCEPTION
	      WHEN OTHERS THEN
	      NULL;
	  END;
	END IF;
 ELSE
    NULL;
 END IF;


	IF p_LPN_ID IS NOT NULL THEN
           BEGIN
              SELECT LICENSE_PLATE_NUMBER
		INTO x_LPN
		FROM WMS_LICENSE_PLATE_NUMBERS
		WHERE LPN_ID = p_LPN_ID  ;
	   EXCEPTION
	      WHEN OTHERS THEN
		 NULL;
	   END;
	 END IF;

    IF p_TRANSFER_LPN_ID IS NOT NULL THEN
      BEGIN
        SELECT LICENSE_PLATE_NUMBER
        INTO x_TRANSFER_LPN
        FROM WMS_LICENSE_PLATE_NUMBERS
        WHERE LPN_ID = p_TRANSFER_LPN_ID  ;
      EXCEPTION
        WHEN OTHERS THEN
         NULL;
      END;
    END IF;
    IF p_CONTENT_LPN_ID IS NOT NULL THEN
      BEGIN
        SELECT LICENSE_PLATE_NUMBER
        INTO x_CONTENT_LPN
        FROM WMS_LICENSE_PLATE_NUMBERS
        WHERE LPN_ID = p_CONTENT_LPN_ID  ;
      EXCEPTION
        WHEN OTHERS THEN
         NULL;
      END;
    END IF;
    IF p_COST_GROUP_ID IS NOT NULL THEN
       BEGIN
          SELECT COST_GROUP
          INTO x_COST_GROUP_NAME
          FROM CST_COST_GROUPS
          WHERE COST_GROUP_ID = p_COST_GROUP_ID;
       EXCEPTION
         WHEN OTHERS THEN
         NULL;
       END;
    END IF;
   IF p_TRANSFER_COST_GROUP_ID IS NOT NULL THEN
       BEGIN
          SELECT COST_GROUP
          INTO x_TRANSFER_COST_GROUP_NAME
          FROM CST_COST_GROUPS
          WHERE COST_GROUP_ID = p_TRANSFER_COST_GROUP_ID;
       EXCEPTION
         WHEN OTHERS THEN
         NULL;
       END;
    END IF;
  IF p_INV_ADV_INSTALLED = 'TRUE' THEN
  BEGIN
    if (p_put_away_strategy_id is not null) then
	select name
	into x_put_away_strategy_name
	from wms_strategies
	where strategy_id = p_put_away_strategy_id;

    end if;

    if (p_put_away_rule_id is not null) then

	select name
	into x_put_away_rule_name
	from wms_rules
	where rule_id = p_put_away_rule_id;
    end if;

    if (p_pick_strategy_id is not null) then
	select name
	into x_pick_strategy_name
	from wms_strategies
	where strategy_id = p_pick_strategy_id;

    end if;

    if (p_pick_rule_id is not null) then
	select name
	into x_pick_rule_name
	from wms_rules
	where rule_id = p_pick_rule_id;

    end if;
   EXCEPTION
      when no_data_found then
	null;
  END;
  END IF;




EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

          ROLLBACK TO get_desc ;
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          ROLLBACK TO get_desc;
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          ROLLBACK TO get_desc;
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( 'INV_VIEW_MTL_TXN', 'GET_DESCRIPTION');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

END GET_DESCRIPTION;
/*
** --------------------------------------------------------------------------
** Procedure :update_mmt_process_cost
** Decription: This procedure updates the mtl_material_transactions table
**             with the cost fetched from the GMF api for the items
**             in process enabled organizations. It updates for the all items
**             having transactions in the given organization between the
**               transaction dates used in the reports, Transaction Register
**               report and Lot Transaction register report.The following
**              columns are passed as input parameters from the reports.
**
**   p_organization_id This is the context organization selected while running
**                      the reports.
**   p_trans_date_from This is the report parameter "From Transaction date"
**   p_trans_date_to   This is the report parameter "To Transaction date"
**   p_report          This value would be T from Transaction register report
**                     And L from Lot Transaction register report.
** --------------------------------------------------------------------------
*/
PROCEDURE update_mmt_process_cost
(
    p_organization_id number
   ,p_trans_date_from DATE
   ,p_trans_date_to DATE
   ,p_report VARCHAR2 DEFAULT 'T')
 IS

    v_gl_cost_mthd		VARCHAR2(4) ;
 v_cost	NUMBER;
    v_ret_val		NUMBER ;
    V_cost_mthd       VARCHAR2(1) DEFAULT NULL ;
    V_cmpntcls_id     NUMBER DEFAULT NULL;
    V_analysis_code   VARCHAR2(1) DEFAULT NULL;
    V_retreive_ind    NUMBER DEFAULT NULL;
    V_cost_cmpntcls_id   NUMBER ;
    V_cost_analysis_code  VARCHAR2(1) DEFAULT NULL;
    V_acctg_cost	NUMBER ;
    l_return_status VARCHAR2(4);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_process_org NUMBER;
    X_num_rows  NUMBER;
    sqlstmt               VARCHAR2(1000);
    TYPE trans_type IS REF CURSOR;
   trans_cur trans_type;
    l_organization_id NUMBER;
    l_inventory_item_id NUMBER;
    l_transaction_date DATE;

    cursor c_process_org IS
    select 1
    from mtl_parameters
    where organization_id = p_organization_id
    and process_enabled_flag = 'Y';

BEGIN
OPEN c_process_org;
FETCH c_process_org INTO l_process_org;
CLOSE c_process_org;

IF l_process_org = 1 THEN
  IF p_report = 'T' THEN
    sqlstmt := 'select distinct i.organization_id ,i.inventory_item_id,
i.transaction_date '
               ||' from mtl_material_Transactions i '
               ||' where i.organization_id = :org_id '
               ||' and i.transaction_date between :from_date '
               ||' and  :to_date ';
  ELSIF p_report = 'L' THEN
       sqlstmt := 'select distinct i.organization_id ,
i.inventory_item_id, i.transaction_date '
               ||' from mtl_material_Transactions i, mtl_transaction_lot_numbers
l '
               ||' where i.transaction_id = l.transaction_id '
               ||' and l.organization_id = :org_id '
               ||' and l.transaction_date between :from_date '
               ||' and  :to_date ';
  END IF;
  OPEN trans_cur for sqlstmt
  USING p_organization_id,p_trans_date_from,p_trans_date_to;
  loop
     fetch trans_cur into l_organization_id,l_inventory_item_id,
l_transaction_date;
     exit when trans_cur%NOTFOUND;

     v_ret_val := GMF_CMCOMMON.get_process_item_cost(
                         p_api_version => 1.0,
                         p_init_msg_list => 'T',
                         p_organization_id => l_organization_id,
                         p_inventory_item_id => l_inventory_item_id,
                         p_transaction_date => l_transaction_date,
                         p_detail_flag => 1,
                         p_cost_method => V_gl_cost_mthd,
                         p_cost_component_class_id => V_cmpntcls_id,
                         p_cost_analysis_code => V_analysis_code,
                         x_total_cost => V_acctg_cost,
                         x_no_of_rows => X_num_rows,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

     if V_ret_val = 1 then
        v_cost := V_acctg_cost ;
     else
       v_cost := 0;
     end if;

       update mtl_material_transactions
       set actual_cost = v_cost
       where organization_id = l_organization_id
       and inventory_item_id = l_inventory_item_id
       and transaction_date = l_transaction_date;
    end loop;
  END IF;
END update_mmt_process_cost;
END INV_VIEW_MTL_TXN;

/
