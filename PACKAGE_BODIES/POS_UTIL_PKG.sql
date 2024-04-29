--------------------------------------------------------
--  DDL for Package Body POS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_UTIL_PKG" AS
/* $Header: POSUTILB.pls 120.1.12000000.3 2007/08/22 11:31:19 pkapoor ship $ */

  FUNCTION bool_to_varchar(b IN BOOLEAN)
    RETURN VARCHAR2 IS
  begin
     IF(b) THEN
	RETURN 'Y';
      ELSE
	RETURN 'N';
     END IF;
  END bool_to_varchar;


/** procedure Retrieve_Doc_Security
    -------------------------------
purpose:
--------
the iSP wrapper api to retrieve where clause for Purchasing Document Security
by calling the PO document security api PO_DOCUMENT_CHECKS_GRP.PO_Security_Check

implementation:
---------------
will give a call to PO_DOCUMENT_CHECKS_GRP.PO_Security_Check 6 times to retrieve the where clause for
 PO - STANDARD, PLANNED
 PA - BLANKET, CONTRACT
 RELEASE - BLANKET, SCHEDULED
*/

  procedure Retrieve_Doc_Security (p_query_table  IN VARCHAR2,
                                   p_owner_id_column  IN VARCHAR2,
                                   p_employee_id IN VARCHAR2,
                                   p_employee_bind_start  IN NUMBER,
                                   p_org_id  IN NUMBER,
                                   x_return_status OUT  NOCOPY  VARCHAR2,
                                   x_msg_data OUT  NOCOPY  VARCHAR2,
                                   x_where_clause OUT  NOCOPY  VARCHAR2)  is

--  l_employee_bind_start  Number;
  l_flag VARCHAR2(1) := 'N';
  l_where_clause VARCHAR2(32000) := '';
  l_call_where_clause VARCHAR2(32000) := '';

BEGIN

   l_where_clause := '((';

 --  l_employee_bind_start  := p_employee_bind_start ;

/*
     PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'PO',
                                               p_document_subtype => 'STANDARD',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''STANDARD''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
  --   l_employee_bind_start  := l_employee_bind_start  + 1;
  end if;


PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'PO',
                                               p_document_subtype => 'PLANNED',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''PLANNED''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
   --  l_employee_bind_start  := l_employee_bind_start  + 1;
 end if;


PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'PA',
                                               p_document_subtype => 'BLANKET',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''BLANKET''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
    -- l_employee_bind_start  := l_employee_bind_start  + 1;
 end if;


PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'PA',
                                               p_document_subtype => 'CONTRACT',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''CONTRACT''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
   --  l_employee_bind_start  := l_employee_bind_start  + 1;
 end if;


PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'RELEASE',
                                               p_document_subtype => 'BLANKET',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''BLANKET''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
    -- l_employee_bind_start  := l_employee_bind_start  + 1;
 end if;


PO_DOCUMENT_CHECKS_GRP.PO_Security_Check(
                                               p_api_version => 1.0,
                                               p_query_table => p_query_table ,
                                               p_owner_id_column => p_owner_id_column ,
                                               p_employee_id => p_employee_id,
                                               p_org_id => p_org_id,
                                               p_minimum_access_level => 'VIEW_ONLY',
                                               p_document_type => 'RELEASE',
                                               p_document_subtype => 'SCHEDULED',
                                               p_type_clause => 'TYPE_LOOKUP_CODE = ''PLANNED''',
                                               x_return_status => x_return_status,
                                               x_msg_data => x_msg_data,
                                               x_where_clause => l_call_where_clause);

*/


l_call_where_clause :=   '(agent_id = '|| p_employee_id || ')  OR  ( ' ||
    '  ( (access_level_code IS NULL OR access_level_code = ''FULL'') OR ' ||
    '    (access_level_code = ''VIEW_ONLY'' AND ''VIEW_ONLY'' NOT IN (''MODIFY'',''FULL'')) OR ' ||
    '    (access_level_code = ''MODIFY'' AND ''VIEW_ONLY''<> ''FULL'')) AND ' ||
    '  ( (security_level_code = ''PUBLIC'')  OR ' ||
    '    (security_level_code IN (''PRIVATE'', ''PURCHASING'', ''HIERARCHY'') ' ||
    '     AND EXISTS ' ||
    '      ( SELECT ''Employee is in approval path of this document''  FROM   PO_ACTION_HISTORY POAH ' ||
    '        WHERE  POAH.employee_id = ' || p_employee_id ||
    '        AND    POAH.object_type_code IN (''PO'', ''PA'') ' ||
    '        AND    POAH.object_id = po_header_id) ) ' ||
    '    OR  ' ||
    '    (security_level_code = ''PURCHASING'' AND EXISTS ' ||
    '      ( SELECT ''User is a BUYER'' FROM po_agents poa ' ||
    '        WHERE poa.agent_id = '|| p_employee_id ||
    '        AND SYSDATE BETWEEN  NVL(POA.start_date_active, SYSDATE) AND  ' ||
    '        NVL(POA.end_date_active, SYSDATE + 1)) ' ||
    '    ) ' ||
    '    OR ' ||
    '    (security_level_code = ''HIERARCHY'' AND EXISTS ' ||
    '       ( SELECT ''User exists in the HIERARCHY'' FROM (SELECT org_id poeh_org_id, position_structure_id, '||
    '                      employee_id, superior_id ' ||
    '                 FROM po_employee_hierarchies) poeh, ' ||
    '                 (SELECT org_id psp_org_id, security_position_structure_id ' ||
    '                   FROM po_system_parameters_all) psp ' ||
    '             WHERE poeh.superior_id   = ' || p_employee_id ||
    '             AND psp.psp_org_id       = org_id  ' ||
    '            AND poeh.employee_id = agent_id ' ||
    '             AND poeh.position_structure_id = ' ||
    '                   NVL(psp.security_position_structure_id,-1) ' ||
    '           )) ) )  ' ;


   if  (l_call_where_clause is not null) then
     if (l_flag = 'N') then
        l_where_clause := l_where_clause || l_call_where_clause;
        l_flag := 'Y';
     else
       l_where_clause := l_where_clause || ') AND (' || l_call_where_clause;
     end if;
     --     l_employee_bind_start  := l_employee_bind_start  + 1;
     end if;

    if (l_flag = 'N') then
         l_where_clause := null;
    else
         l_where_clause := l_where_clause || '))';
    end if;

    x_where_clause := l_where_clause;

 EXCEPTION when others then

     x_where_clause := null;
     x_return_status := 'U';
     x_msg_data := sqlcode || ':' || sqlerrm(sqlcode);

 END Retrieve_Doc_Security;



 PROCEDURE update_revision (p_organizationId in number,
                           p_inventoryItemId in number,
                           p_vendorId in number,
                           p_batchId in number,
                           x_returnCode out NOCOPY varchar,
                           x_err_msg out NOCOPY varchar) is

PURCHASING_BY_REV      CONSTANT INTEGER := 1;
NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;
UNDER_REV_CONTROL      CONSTANT INTEGER := 2;
NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;
var_purchasing_by_rev  NUMBER := to_number(FND_PROFILE.VALUE('MRP_PURCHASING_BY_REVISION'));

var_revision        VARCHAR2(3);
var_revision_ctrl   NUMBER;

BEGIN

  BEGIN
    SELECT max(rev.revision),
           max(msi.revision_qty_control_code)
    INTO   var_revision, var_revision_ctrl
    FROM   mtl_system_items_b msi,
           mtl_item_revisions rev
    WHERE  msi.inventory_item_id = p_inventoryItemId
    AND    msi.organization_id = p_organizationId
    AND    rev.inventory_item_id = msi.inventory_item_id
    AND    rev.organization_id = msi.organization_id
    AND    TRUNC(rev.effectivity_date) =
           (SELECT TRUNC(max(rev2.effectivity_date))
            FROM    mtl_item_revisions rev2
            WHERE   rev2.implementation_date IS NOT NULL
            AND     rev2.effectivity_date <= TRUNC(SYSDATE)+.99999
            AND     rev2.organization_id = rev.organization_id
            AND     rev2.inventory_item_id = rev.inventory_item_id);

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      var_revision_ctrl := NOT_UNDER_REV_CONTROL;
    WHEN OTHERS THEN
       x_returnCode := 'U';
       x_err_msg := sqlerrm;
       RAISE;
  END;

  BEGIN
       UPDATE PO_REQUISITIONS_INTERFACE
       set    item_revision = DECODE(var_purchasing_by_rev, NULL,
                              DECODE(var_revision_ctrl, NOT_UNDER_REV_CONTROL, NULL, var_revision),
                                     PURCHASING_BY_REV, var_revision,
                                     NOT_PURCHASING_BY_REV, NULL)
       WHERE BATCH_ID = p_batchId;

  EXCEPTION
    WHEN OTHERS THEN
       x_returnCode := 'U';
       x_err_msg := sqlerrm;
       RAISE;
  END;

  x_returnCode := 'S';
  x_err_msg := 'SUCCESS';

END update_revision;


/** function IS_FV_ENABLED
    -----------------------
purpose:
--------
The iSP wrapper api to retrieve the value of Profile Option FV: Federal Enabled
by calling the Federal Financial api fv_install.enabled.
Returns 'T' if the Federal is enabled otherwise 'F'.

*/

FUNCTION IS_FV_ENABLED RETURN VARCHAR2
  IS
BEGIN
IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.string(
			fnd_log.level_statement,
			g_log_module_name,
			' starts IS_FV_ENABLED '
		      );
END IF;
if(fv_install.enabled) then
  RETURN 'T';
else
  RETURN 'F';
end if;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20060, 'Failure in IS_FV_ENABLED ', true);
END;


/** PROCEDURE FV_IS_CCR
    -----------------------
purpose:
--------
The iSP wrapper api to know if record is in CCR,
by calling the Federal Financial api FV_CCR_GRP.FV_IS_CCR

p_object_type, p_object_id:
Here S-> Supplier  --> Pass supplier_id
     B=> Bank branch  --> pass bank brnahc id
     T=> Supplier site -->  Pass Pay site or main address site id
     A-> Bank account Bank account id
*/
PROCEDURE FV_IS_CCR
(       p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2 ,
        p_object_id                     IN      NUMBER,
        p_object_type           IN VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2,
        x_ccr_id                        OUT     NOCOPY NUMBER,
        x_out_status            OUT     NOCOPY VARCHAR2,
        x_error_code            OUT NOCOPY NUMBER
)
IS
BEGIN
IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.string(
			fnd_log.level_statement,
			g_log_module_name,
			' start FV_IS_CCR'
		      );
END IF;

IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.string(
			fnd_log.level_statement,
			g_log_module_name,
			'Calling FV_CCR_GRP.FV_IS_CCR with p_object_id = '||p_object_id||' p_object_type = '||p_object_type
		      );
END IF;
FV_CCR_GRP.FV_IS_CCR(
  p_api_version,
  p_init_msg_list,
  p_object_id,
  p_object_type,
  x_return_status,
  x_msg_count,
  x_msg_data,
  x_ccr_id,
  x_out_status,
  x_error_code
);
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20060, 'Failure in FV_CCR_GRP.FV_IS_CCR ', true);
END FV_IS_CCR;


/** function IS_ADDR_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if there is any CCR Site associated
to an address
p_object_id: party_site_id for the address.

Returns 'T' if the Address has atleast one CCR site, otherwise 'F'

*/
FUNCTION IS_ADDR_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2
IS
l_out_status     	VARCHAR2(1);
is_enabled 		VARCHAR2(1);
l_return_status     	VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_error_code            NUMBER;
l_ccr_id                NUMBER;
cursor l_addr_site_cur is
select vendor_site_id from ap_supplier_sites_all
WHERE party_site_id = p_object_id;
BEGIN
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
		  fnd_log.level_statement,
		  g_log_module_name,
		  'Start IS_ADDR_CCR with p_object_id = '||p_object_id
		);
	END IF;
	l_out_status := 'F';
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
		  fnd_log.level_statement,
		  g_log_module_name,
		  'Calling pos_util_pkg.IS_FV_ENABLED'
		);
	END IF;
	is_enabled := pos_util_pkg.IS_FV_ENABLED();
        IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(
                  fnd_log.level_statement,
                  g_log_module_name,
                  'After pos_util_pkg.IS_FV_ENABLED is_enabled = '||is_enabled
                );
        END IF;
	if is_enabled <> 'T' then
		return l_out_status;
	else
		for  i in l_addr_site_cur  loop
			IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.string(
				  fnd_log.level_statement,
				  g_log_module_name,
				  'Calling FV_CCR_GRP.FV_IS_CCR with i.vendor_site_id = '||i.vendor_site_id
		      	 	  );
			END IF;
			FV_CCR_GRP.FV_IS_CCR(
			  p_api_version,
			  p_init_msg_list,
			  i.vendor_site_id,
			  'T',
			  l_return_status,
			  l_msg_count,
			  l_msg_data,
			  l_ccr_id,
			  l_out_status,
			  l_error_code
			);
			IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                FND_LOG.string(
                                  fnd_log.level_statement,
                                  g_log_module_name,
                                  'After Calling FV_CCR_GRP.FV_IS_CCR with i.vendor_site_id = '||i.vendor_site_id||' l_return_status ='||l_return_status||'l_out_status = '||l_out_status
                                );
                        END IF;

			if l_out_status <> 'F' then
				return l_out_status;
			end if;
		end loop;
	end if;
IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.string(
			fnd_log.level_statement,
			g_log_module_name,
			'End IS_ADDR_CCR with p_object_id = '||p_object_id||'l_out_status = '||l_out_status
		      );
END IF;
return l_out_status;
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20060, 'Failure in IS_ADDR_CCR ', true);
END ;


/** function IS_SITE_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if site is a CCR Site
p_object_id: vendor_site_id

Returns 'T' if the site is CCR Site otherwise 'F'

*/
FUNCTION IS_SITE_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2
IS
l_out_status            VARCHAR2(1);
is_enabled              VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_error_code            NUMBER;
l_ccr_id                NUMBER;
BEGIN
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
		  fnd_log.level_statement,
		  g_log_module_name,
		  'Start IS_SITE_CCR with p_object_id = '||p_object_id
		);
	END IF;
        l_out_status := 'F';
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
		  fnd_log.level_statement,
		  g_log_module_name,
		  'Calling pos_util_pkg.IS_FV_ENABLED'
	        );
	END IF;
        is_enabled := pos_util_pkg.IS_FV_ENABLED();
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
		  fnd_log.level_statement,
		  g_log_module_name,
		  'After Calling pos_util_pkg.IS_FV_ENABLED is_enabled = '||is_enabled
		);
	END IF;

        if is_enabled <> 'T' then
                return l_out_status;
        else
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
		THEN
			FND_LOG.string(
			  fnd_log.level_statement,
			  g_log_module_name,
			  'Calling FV_CCR_GRP.FV_IS_CCR with p_object_id = '||p_object_id
			);
		END IF;
                FV_CCR_GRP.FV_IS_CCR(
		  p_api_version,
		  p_init_msg_list,
		  p_object_id,
		  'T',
		  l_return_status,
		  l_msg_count,
		  l_msg_data,
		  l_ccr_id,
		  l_out_status,
		  l_error_code
		);
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
		THEN
			FND_LOG.string(
			  fnd_log.level_statement,
			  g_log_module_name,
			  'After Calling FV_CCR_GRP.FV_IS_CCR l_out_status = '||l_out_status
			);
		END IF;
        end if;
return l_out_status;
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20060, 'Failure in IS_SITE_CCR ', true);
END ;


/** function IS_SUPP_CCR
    -----------------------
purpose:
--------
The iSP wrapper api over FV_IS_CCR to know if Supplier is a CCR Supplier.
p_object_id: vendor_id.

Returns 'T' if the supplier is CCR Supplier otherwise 'F'

*/

FUNCTION IS_SUPP_CCR(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2
IS
l_out_status            VARCHAR2(1);
is_enabled              VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_error_code            NUMBER;
l_ccr_id                NUMBER;
BEGIN
        l_out_status := 'F';
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.string(
	  	  fnd_log.level_statement,
		  g_log_module_name,
		  'Start IS_SUPP_CCR with p_object_id = '||p_object_id
		);
	END IF;
        IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(
                  fnd_log.level_statement,
                  g_log_module_name,
                  'Calling pos_util_pkg.IS_FV_ENABLED'
                );
        END IF;
        is_enabled := pos_util_pkg.IS_FV_ENABLED();
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(
                  fnd_log.level_statement,
                  g_log_module_name,
                  'After Calling pos_util_pkg.IS_FV_ENABLED is_enabled ='||is_enabled
                );
        END IF;
        if is_enabled <> 'T' then
                return l_out_status;
        else
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
		THEN
			FND_LOG.string(
			  fnd_log.level_statement,
			  g_log_module_name,
			  'Calling FV_CCR_GRP.FV_IS_CCR with p_object_id = '||p_object_id
			);
		END IF;
                FV_CCR_GRP.FV_IS_CCR(
		  p_api_version,
		  p_init_msg_list,
		  p_object_id,
		  'S',
		  l_return_status,
		  l_msg_count,
		  l_msg_data,
		  l_ccr_id,
		  l_out_status,
		  l_error_code
		);
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
		THEN
                        FND_LOG.string(
                          fnd_log.level_statement,
                          g_log_module_name,
                          'After Calling FV_CCR_GRP.FV_IS_CCR with l_out_status = '||l_out_status
                        );
                END IF;
        end if;
return l_out_status;
END ;

/** function IS_CCR_SITE_ACTIVE
    -----------------------
purpose:
--------
The iSP wrapper api over FV_CCR_GRP.FV_CCR_REG_STATUS to know if site is CCR
site and if registration_status is active.
p_object_id: vendor_site_id.

Returns 'T' if the site is CCR Site and registration_status is active otherwise
'F'

*/

FUNCTION IS_CCR_SITE_ACTIVE(
 p_api_version           IN      NUMBER,
 p_init_msg_list         IN      VARCHAR2 ,
 p_object_id             IN      NUMBER
 )RETURN VARCHAR2
IS
l_out_status            VARCHAR2(1);
is_enabled              VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_error_code            NUMBER;
l_ccr_id                NUMBER;
BEGIN
	IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(
                  fnd_log.level_statement,
                  g_log_module_name,
                  'Start IS_CCR_SITE_ACTIVE with p_object_id = '||p_object_id
                );
        END IF;
        IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(
                  fnd_log.level_statement,
                  g_log_module_name,
                  'Calling pos_util_pkg.IS_FV_ENABLED'
                );
        END IF;
        l_out_status := 'F';

        is_enabled := pos_util_pkg.IS_FV_ENABLED();
        if is_enabled <> 'T' then
                return 'F';
        else
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                THEN
                        FND_LOG.string(
                          fnd_log.level_statement,
                          g_log_module_name,
                          'Calling FV_CCR_GRP.FV_IS_CCR with p_object_id = '||p_object_id
                        );
                END IF;

                FV_CCR_GRP.FV_IS_CCR(
		  p_api_version,
		  p_init_msg_list,
		  p_object_id,
		  'T',
		  l_return_status,
		  l_msg_count,
		  l_msg_data,
		  l_ccr_id,
		  l_out_status,
		  l_error_code
		);
		IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                THEN
                        FND_LOG.string(
                          fnd_log.level_statement,
                          g_log_module_name,
                          'After Calling FV_CCR_GRP.FV_IS_CCR with l_out_status = '||l_out_status
                        );
                END IF;

		if l_out_status <> 'T' then
			return 'F';
		else
			IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
	                THEN
                	        FND_LOG.string(
        	                  fnd_log.level_statement,
	                          g_log_module_name,
                	          'Calling FV_CCR_GRP.FV_CCR_REG_STATUS with p_object_id = '||p_object_id
        	                );
	                END IF;
			FV_CCR_GRP.FV_CCR_REG_STATUS(
			  p_api_version,
			  p_init_msg_list,
			  p_object_id,
			  l_return_status,
			  l_msg_count,
			  l_msg_data,
			  l_out_status,
			  l_error_code
			);
			IF (fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
                        THEN
                                FND_LOG.string(
                                  fnd_log.level_statement,
                                  g_log_module_name,
                                  'After Calling FV_CCR_GRP.FV_CCR_REG_STATUS with l_out_status = '||l_out_status
                                );
                        END IF;

		end if;
        end if;
return l_out_status;
EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20060, 'Failure in IS_CCR_SITE_ACTIVE', true);
END ;

end pos_util_pkg;

/
