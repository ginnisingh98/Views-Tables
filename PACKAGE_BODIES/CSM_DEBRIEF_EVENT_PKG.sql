--------------------------------------------------------
--  DDL for Package Body CSM_DEBRIEF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DEBRIEF_EVENT_PKG" AS
/* $Header: csmedebb.pls 120.1.12010000.2 2008/08/07 05:42:01 trajasek ship $ */

g_debrief_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_LINES_ACC';
g_debrief_table_name            CONSTANT VARCHAR2(30) := 'CSF_DEBRIEF_LINES';
g_debrief_seq_name              CONSTANT VARCHAR2(30) := 'CSM_DEBRIEF_LINES_ACC_S';
g_debrief_pk1_name              CONSTANT VARCHAR2(30) := 'DEBRIEF_LINE_ID';
g_debrief_pubi_name             CSM_ACC_PKG.t_publication_item_list;
g_labor_billing_type_category   CONSTANT VARCHAR2(30) := 'L';

g_systemitems_table_name            CONSTANT VARCHAR2(30) := 'MTL_SYSTEM_ITEMS_B';
g_systemitems_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_SYSTEM_ITEMS_ACC';
g_systemitems_acc_seq_name     CONSTANT VARCHAR2(30) := 'CSM_SYSTEM_ITEMS_ACC_S';
g_systemitems_pubi_name CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_SYSTEM_ITEMS');
g_systemitems_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_systemitems_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';

/*
g_counters_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTERS');
  */

/** Returns the name of the debrief Publication Item based upon the billing type **/
function GET_DEBRIEF_PI_NAME (p_material_bill_type  cs_txn_billing_types.billing_type%TYPE)
return varchar2
is
l_debrief_pi_name varchar2(30);
l_no_billing_type_excp exception;
begin
  if (p_material_bill_type = 'L') then
    return 'CSF_M_DEBRIEF_LABOR';
  elsif (p_material_bill_type = 'E') then
    return 'CSF_M_DEBRIEF_EXPENSES';
  elsif (p_material_bill_type = 'M') then
    return 'CSF_M_DEBRIEF_PARTS';
  else
    raise l_no_billing_type_excp;
  end if;
END GET_DEBRIEF_PI_NAME;

FUNCTION MATERIAL_BILLABLE_FLAG(p_debrief_line_id IN NUMBER, p_inventory_item_id IN NUMBER,
                                p_user_id IN NUMBER)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_billing_type_category cs_billing_type_categories.billing_category%TYPE;

--getting billing category using transaction type id
CURSOR l_txn_billing_csr(p_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE, p_user_id IN NUMBER)
IS
SELECT cbtc.billing_category
FROM csf_debrief_lines lines,
     mtl_system_items_b msi,
     cs_txn_billing_types txbt,
     CS_BILLING_TYPE_CATEGORIES cbtc
WHERE lines.debrief_line_id = p_debrief_line_id
AND msi.inventory_item_id = lines.inventory_item_id
AND msi.organization_id = NVL(NVL(lines.issuing_inventory_org_id, lines.receiving_inventory_org_id), csm_profile_pkg.get_organization_id(p_user_id))
AND lines.transaction_type_id = txbt.transaction_type_id
AND msi.material_billable_flag = txbt.billing_type
AND txbt.billing_type = cbtc.billing_type;

--getting billing category using Billing type id
CURSOR l_txn_billing_type_csr(p_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE)
IS
SELECT  cbtc.billing_category
FROM 	csf_debrief_lines lines,
     	cs_txn_billing_types txbt,
     	CS_BILLING_TYPE_CATEGORIES cbtc
WHERE 	lines.debrief_line_id 	  = p_debrief_line_id
AND 	lines.txn_billing_type_id = txbt.txn_billing_type_id
AND 	txbt.billing_type 		  = cbtc.billing_type;

BEGIN
   l_billing_type_category := NULL;
   OPEN l_txn_billing_csr(p_debrief_line_id, p_user_id);
   FETCH l_txn_billing_csr INTO l_billing_type_category;
   IF l_txn_billing_csr%NOTFOUND THEN
      --getting billing category using billing type in debrief lines
        OPEN l_txn_billing_type_csr(p_debrief_line_id);
      	FETCH l_txn_billing_type_csr INTO l_billing_type_category;


       --Get the inventory item id for the debrief line
       --If the inventory item id is null then the debrief line
       --has to be considered as Labor line as per 11.5.9 CSF
       --Material and Expense Lines require inventory item id as mandatory

       --LOTR: At this point, we know that csr didnt return and inv_item is not null
       --so we need to classify it as material or labour. How??
      IF l_txn_billing_type_csr%NOTFOUND THEN
        IF p_inventory_item_id IS NULL THEN
          l_billing_type_category := g_labor_billing_type_category;
        END IF;
      END IF;
      CLOSE l_txn_billing_type_csr;
   END IF;
   CLOSE l_txn_billing_csr;
   RETURN l_billing_type_category;

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  MATERIAL_BILLABLE_FLAG for debrief_line_id: ' || p_debrief_line_id
                          || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.MATERIAL_BILLABLE_FLAG',FND_LOG.LEVEL_EXCEPTION);
        RETURN l_billing_type_category;
END MATERIAL_BILLABLE_FLAG;

PROCEDURE DEBRIEF_LINES_ACC_I(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINES_ACC_I for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_I',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list(get_debrief_pi_name (p_billing_category))
     ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
     ,P_SEQ_NAME               => g_debrief_seq_name
     ,P_PK1_NAME               => g_debrief_pk1_name
     ,P_PK1_NUM_VALUE          => p_debrief_line_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINES_ACC_I for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINES_ACC_I for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINES_ACC_I;

PROCEDURE DEBRIEF_LINE_INS_INIT (p_debrief_line_id IN NUMBER, p_h_user_id IN NUMBER,
                                 p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id  NUMBER;
l_material_billable_flag VARCHAR2(1);
l_labor_exp_organization_id NUMBER;

CURSOR l_csm_debrfLnInsInit_csr (p_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE)
IS
SELECT dhdr.task_assignment_id, jtrs.user_id, jta.resource_id ,dbl.inventory_item_id, dbl.instance_id,
       NVL(NVL(issuing_inventory_org_id, receiving_inventory_org_id), csm_profile_pkg.get_organization_id(jtrs.user_id)) AS organization_id
FROM csf_debrief_lines dbl,
     csf_debrief_headers dhdr,
		 jtf_task_assignments jta,
		 jtf_rs_resource_extns jtrs
WHERE dbl.debrief_line_id = p_debrief_line_id
AND  dbl.debrief_header_id = dhdr.debrief_header_id
AND  jta.task_assignment_id = dhdr.task_assignment_id
AND  jtrs.resource_id (+)= jta.resource_id
;

l_csm_debrfLnInsInit_rec l_csm_debrfLnInsInit_csr%ROWTYPE;
l_csm_debrfLnInsInit_null l_csm_debrfLnInsInit_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINE_INS_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_csm_debrfLnInsInit_rec := l_csm_debrfLnInsInit_null;

   OPEN l_csm_debrfLnInsInit_csr(p_debrief_line_id);
   FETCH l_csm_debrfLnInsInit_csr INTO l_csm_debrfLnInsInit_rec;
   IF l_csm_debrfLnInsInit_csr%NOTFOUND THEN
      CLOSE l_csm_debrfLnInsInit_csr;
      RETURN;
   END IF;
   CLOSE l_csm_debrfLnInsInit_csr;

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
       IF ( NOT (CSM_UTIL_PKG.is_palm_resource(l_csm_debrfLnInsInit_rec.resource_id))) THEN
         CSM_UTIL_PKG.LOG('Not a mobile resource for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
         RETURN;
       END IF;
       l_user_id := l_csm_debrfLnInsInit_rec.user_id;
       l_labor_exp_organization_id := l_csm_debrfLnInsInit_rec.organization_id;
   ELSE
       l_user_id := p_h_user_id;
       l_labor_exp_organization_id := csm_profile_pkg.get_organization_id(l_user_id);
   END IF;

   -- get material billable flag of the debrief line
   l_material_billable_flag := material_billable_flag(p_debrief_line_id=>p_debrief_line_id,
                                    p_inventory_item_id=>l_csm_debrfLnInsInit_rec.inventory_item_id,
                                    p_user_id=>l_user_id);

   IF l_material_billable_flag IN ('L','E') THEN -- labor, expense line
      -- insert into csm_system_items_acc is inventory_item_id is not null
      IF l_csm_debrfLnInsInit_rec.inventory_item_id IS NOT NULL THEN
         csm_system_item_event_pkg.system_item_mdirty_i(p_inventory_item_id=>l_csm_debrfLnInsInit_rec.inventory_item_id,
                                                        p_organization_id=>l_labor_exp_organization_id,
                                                        p_user_id=>l_user_id);
      END IF;
   ELSIF l_material_billable_flag = ('M') THEN-- material line
      -- insert instance_id into acc table
      IF l_csm_debrfLnInsInit_rec.instance_id IS NOT NULL THEN
         csm_item_instance_event_pkg.item_instances_acc_processor(p_instance_id=>l_csm_debrfLnInsInit_rec.instance_id,
                                                                  p_user_id=>l_user_id,
                                                                  p_flowtype=>p_flow_type,
                                                                  p_error_msg=>l_error_msg,
                                                                  x_return_status=>l_return_status);
      END IF;
   END IF;

   IF l_material_billable_flag IS NOT NULL THEN -- only for labor, expense and Material line
      -- insert debrief line into acc table
        DEBRIEF_LINES_ACC_I(p_debrief_line_id=>p_debrief_line_id,
                            p_billing_category=>l_material_billable_flag,
                            p_user_id=>l_user_id);
   END IF;
   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINE_INS_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINE_INS_INIT for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINE_INS_INIT;

PROCEDURE DEBRIEF_LINE_DEL_INIT (p_debrief_line_id IN NUMBER, p_user_id IN NUMBER,
                                 p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_user_id  NUMBER;
l_material_billable_flag VARCHAR2(1);

CURSOR l_csm_debrfLnDel_csr (p_debrief_line_id csf_debrief_lines.debrief_line_id%TYPE, p_user_id IN NUMBER)
IS
SELECT acc.user_id, dbl.inventory_item_id, dbl.instance_id,
       NVL(NVL(dbl.issuing_inventory_org_id, dbl.receiving_inventory_org_id), csm_profile_pkg.get_organization_id(p_user_id)) AS organization_id
FROM csf_debrief_lines dbl,
     csm_debrief_lines_acc acc
WHERE dbl.debrief_line_id = p_debrief_line_id
AND  acc.debrief_line_id = dbl.debrief_line_id
AND  acc.user_id = p_user_id;

l_csm_debrfLnDel_rec l_csm_debrfLnDel_csr%ROWTYPE;
l_csm_debrfLnDel_null l_csm_debrfLnDel_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINE_DEL_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
   l_csm_debrfLnDel_rec := l_csm_debrfLnDel_null;

   OPEN l_csm_debrfLnDel_csr(p_debrief_line_id, p_user_id);
   FETCH l_csm_debrfLnDel_csr INTO l_csm_debrfLnDel_rec;
   IF l_csm_debrfLnDel_csr%NOTFOUND THEN
      CLOSE l_csm_debrfLnDel_csr;
      RETURN;
   END IF;
   CLOSE l_csm_debrfLnDel_csr;
   -- no need to check if its history as the line has to be deleted from the acc table
   -- get material billable flag of the debrief line
   l_material_billable_flag := material_billable_flag(p_debrief_line_id=>p_debrief_line_id,
                                    p_inventory_item_id=>l_csm_debrfLnDel_rec.inventory_item_id,
                                    p_user_id=>p_user_id);
   IF l_material_billable_flag IN ('L','E') THEN -- labor, expense line
      -- insert into csm_system_items_acc is inventory_item_id is not null
      IF l_csm_debrfLnDel_rec.inventory_item_id IS NOT NULL THEN
         csm_system_item_event_pkg.system_item_mdirty_d(p_inventory_item_id=>l_csm_debrfLnDel_rec.inventory_item_id,
                                                        p_organization_id=>l_csm_debrfLnDel_rec.organization_id,
                                                        p_user_id=>p_user_id);
      END IF;
   ELSIF l_material_billable_flag = ('M') THEN-- material line
        -- delete instance_id from acc table
      IF l_csm_debrfLnDel_rec.instance_id IS NOT NULL THEN
         csm_item_instance_event_pkg.item_instances_acc_d(p_instance_id=>l_csm_debrfLnDel_rec.instance_id,
                                                          p_user_id=>p_user_id,
                                                          p_error_msg=>l_error_msg,
                                                         x_return_status=>l_return_status);
      END IF;
   END IF;
   IF l_material_billable_flag IS NOT NULL THEN -- only for labor, expense and Material line
        -- delete debrief line from acc table
        debrief_lines_acc_d(p_debrief_line_id=>p_debrief_line_id,
                            p_billing_category=>l_material_billable_flag,
                            p_user_id=>p_user_id);
   END IF;
   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINE_DEL_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINE_DEL_INIT for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINE_DEL_INIT;

PROCEDURE DEBRIEF_LINES_ACC_D(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINES_ACC_D for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_D',FND_LOG.LEVEL_PROCEDURE);

   CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list(get_debrief_pi_name (p_billing_category))
     ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
     ,P_PK1_NAME               => g_debrief_pk1_name
     ,P_PK1_NUM_VALUE          => p_debrief_line_id
     ,P_USER_ID                => p_user_id
    );
   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINES_ACC_D for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINES_ACC_D for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINES_ACC_D;

PROCEDURE DEBRIEF_LINE_UPD_INIT(p_debrief_line_id IN NUMBER, p_old_inventory_item_id IN NUMBER,
                                p_is_inventory_item_updated IN VARCHAR2, p_old_instance_id IN NUMBER,
                                p_is_instance_updated IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_material_billable_flag VARCHAR2(1);

CURSOR l_csm_debrfLnUpdInit_csr (p_debrief_line_id csf_debrief_lines.debrief_line_id%type) IS
SELECT dhdr.task_assignment_id,
       jtrs.user_id,
	   jta.resource_id,
	   dbl.inventory_item_id,
       dbl.instance_id,
       NVL(nvl(issuing_inventory_org_id, receiving_inventory_org_id), csm_profile_pkg.get_organization_id(jtrs.user_id)) AS organization_id,
       acc.access_id
FROM csf_debrief_lines dbl,
     csf_debrief_headers dhdr,
     csm_debrief_lines_acc acc,
	 jtf_task_assignments jta,
	 jtf_rs_resource_extns jtrs
WHERE dbl.debrief_line_id = p_debrief_line_id
AND  dbl.debrief_header_id = dhdr.debrief_header_id
AND  jta.task_assignment_id = dhdr.task_assignment_id
AND  jtrs.resource_id = jta.resource_id
AND  acc.debrief_line_id = dbl.debrief_line_id
AND  acc.user_id = jtrs.user_id
;

l_csm_debrfLnUpdInit_rec l_csm_debrfLnUpdInit_csr%ROWTYPE;
l_csm_debrfLnUpdInit_null l_csm_debrfLnUpdInit_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINE_UPD_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);

   l_csm_debrfLnUpdInit_rec := l_csm_debrfLnUpdInit_null;

   OPEN l_csm_debrfLnUpdInit_csr(p_debrief_line_id);
   FETCH l_csm_debrfLnUpdInit_csr INTO l_csm_debrfLnUpdInit_rec;
   IF l_csm_debrfLnUpdInit_csr%NOTFOUND THEN
      CLOSE l_csm_debrfLnUpdInit_csr;
      RETURN;
   END IF;
   CLOSE l_csm_debrfLnUpdInit_csr;

   -- get material billable flag of the debrief line
   l_material_billable_flag := material_billable_flag(p_debrief_line_id=>p_debrief_line_id,
                                    p_inventory_item_id=>l_csm_debrfLnUpdInit_rec.inventory_item_id,
                                    p_user_id=>l_csm_debrfLnUpdInit_rec.user_id);

   IF l_material_billable_flag IS NOT NULL THEN -- only for labor, expense and Material line
      -- mark dirty the debrief line
      DEBRIEF_LINES_ACC_U(p_debrief_line_id=>p_debrief_line_id,
                       p_billing_category=>l_material_billable_flag,
                       p_access_id=>l_csm_debrfLnUpdInit_rec.access_id,
                       p_user_id=>l_csm_debrfLnUpdInit_rec.user_id);
   END IF;

   IF l_material_billable_flag IN ('L','E') THEN -- labor, expense line
      IF p_is_inventory_item_updated = 'Y' THEN
        -- insert the new inventory item
        IF l_csm_debrfLnUpdInit_rec.inventory_item_id IS NOT NULL THEN
          csm_system_item_event_pkg.system_item_mdirty_i(p_inventory_item_id=>l_csm_debrfLnUpdInit_rec.inventory_item_id,
                                                         p_organization_id=>l_csm_debrfLnUpdInit_rec.organization_id,
                                                         p_user_id=>l_csm_debrfLnUpdInit_rec.user_id);
        END IF;

        -- delete the old inventory item
        IF p_old_inventory_item_id IS NOT NULL THEN
          csm_system_item_event_pkg.system_item_mdirty_d(p_inventory_item_id=>p_old_inventory_item_id,
                                                         p_organization_id=>l_csm_debrfLnUpdInit_rec.organization_id,
                                                         p_user_id=>l_csm_debrfLnUpdInit_rec.user_id);
        END IF;
      END IF;
   ELSIF l_material_billable_flag = ('M') THEN-- material line
      IF p_is_instance_updated = 'Y' THEN
        -- insert the new instance
        IF l_csm_debrfLnUpdInit_rec.instance_id IS NOT NULL THEN
          csm_item_instance_event_pkg.item_instances_acc_processor(p_instance_id=>l_csm_debrfLnUpdInit_rec.instance_id,
                                                                   p_user_id=>l_csm_debrfLnUpdInit_rec.user_id,
                                                                   p_flowtype=>NULL,
                                                                   p_error_msg=>l_error_msg,
                                                                   x_return_status=>l_return_status);
        END IF;

        -- delete the old instance
        IF p_old_instance_id IS NOT NULL THEN
          csm_item_instance_event_pkg.item_instances_acc_d(p_instance_id=>p_old_instance_id,
                                                          p_user_id=>l_csm_debrfLnUpdInit_rec.user_id,
                                                          p_error_msg=>l_error_msg,
                                                          x_return_status=>l_return_status);
        END IF;
      END IF;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINE_UPD_INIT for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINE_UPD_INIT for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINE_UPD_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINE_UPD_INIT;

PROCEDURE DEBRIEF_LINES_ACC_U(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_access_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DEBRIEF_LINES_ACC_U for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_U',FND_LOG.LEVEL_PROCEDURE);

      CSM_ACC_PKG.Update_Acc
          ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list(get_debrief_pi_name (p_billing_category))
           ,P_ACC_TABLE_NAME         => g_debrief_acc_table_name
           ,P_ACCESS_ID              => p_access_id
           ,P_USER_ID                => p_user_id
          );

   CSM_UTIL_PKG.LOG('Leaving DEBRIEF_LINES_ACC_U for debrief_line_id: ' || p_debrief_line_id,
                                   'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_U',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DEBRIEF_LINES_ACC_U for debrief_line_id:'
                       || to_char(p_debrief_line_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_DEBRIEF_EVENT_PKG.DEBRIEF_LINES_ACC_U',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END DEBRIEF_LINES_ACC_U;

END CSM_DEBRIEF_EVENT_PKG;

/
