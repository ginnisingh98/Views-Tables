--------------------------------------------------------
--  DDL for Package Body AMW_FINSTMT_FINDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FINSTMT_FINDING_PVT" AS
/* $Header: amwffinb.pls 120.0 2005/05/31 19:58:31 appldev noship $ */


G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_FINSTMT_FINDING_PVT';
G_API_NAME   CONSTANT VARCHAR2 (15) := 'amwffinb.pls';

PROCEDURE POPULATE_FINSTMT_FINDINGS(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2,
                      p_certification_id IN NUMBER)
IS

CURSOR Get_Cert is
Select distinct CERTIFICATION_ID
from AMW_CERTIFICATION_VL
where object_type = 'FIN_STMT' and
CERTIFICATION_STATUS in ('ACTIVE','DRAFT');

l_certification_id NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'POPULATE_FINSTMT_FINDINGS';

BEGIN

l_certification_id := p_certification_id;



IF(l_certification_id IS NULL) THEN

for Get_Cert_rec in Get_Cert loop
exit when Get_Cert %notfound;
Populate_Fin_Summary(Get_Cert_rec.CERTIFICATION_ID);
end loop;

ELSE
Populate_Fin_Summary(p_certification_id => l_certification_id);
END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in ' ||   G_PKG_NAME || '.' || l_api_name
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
     WHEN OTHERS THEN
     fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in ' ||   G_PKG_NAME || '.' || l_api_name
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;

  END POPULATE_FINSTMT_FINDINGS;


PROCEDURE Populate_Fin_Summary
(p_certification_id IN NUMBER)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Summary';

BEGIN

 SAVEPOINT Populate_Fin_Summary;

 fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

 update amw_fin_process_eval_sum set
    LAST_UPDATE_DATE = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.conc_login_id,
    OPEN_FINDINGS = amw_findings_pkg.calculate_open_findings('AMW_PROJ_FINDING', 'PROJ_ORG_PROC', process_id, 'PROJ_ORG', organization_id, null, null, null, null, null, null)
    where fin_certification_id = p_certification_id;

 update amw_fin_org_eval_sum set
    LAST_UPDATE_DATE = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.conc_login_id,
    OPEN_FINDINGS = amw_findings_pkg.calculate_open_findings ('AMW_PROJ_FINDING', 'PROJ_ORG', organization_id, null, null,null, null,null, null, null, null )
    where fin_certification_id = p_certification_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
      WHEN OTHERS THEN
       ROLLBACK TO Populate_Fin_Summary;
      fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Finding_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

END Populate_Fin_Summary;

END AMW_FINSTMT_FINDING_PVT;

/
