--------------------------------------------------------
--  DDL for Package Body JE_GR_TRNOVR_RULES_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_GR_TRNOVR_RULES_UPGRADE" AS
/* $Header: jegrupgb.pls 120.2 2006/11/03 08:24:43 anvijaya ship $ */

PROCEDURE upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number) IS

l_message VARCHAR2(1000);
l_row_count NUMBER := 0;

l_org_id NUMBER(15);
l_return_status VARCHAR2(10);
l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
l_legal_entity_id NUMBER;

BEGIN

retcode := 0;
errbuf := NULL;

-- Get the profile org id.
l_org_id := FND_PROFILE.VALUE('ORG_ID');

IF l_org_id IS NOT NULL THEN

    fnd_file.put_line(fnd_file.log, 'Org id: '||l_org_id);

l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(l_org_id);
/*    xle_upgrade_utils.get_default_legal_context(x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data  => l_msg_data,
		p_org_id => l_org_id,
		x_dlc    => l_legal_entity_id);
*/
    fnd_file.put_line(fnd_file.log, 'Ret Status: '||l_return_status);
    fnd_file.put_line(fnd_file.log, 'Msg Data: '||l_msg_data);

    -- If the return status is not error, then continue with the process
    IF l_return_status IS NULL THEN

          IF (l_legal_entity_id IS NOT NULL) THEN

                     UPDATE je_gr_trnovr_rules
                     SET legal_entity_id = l_legal_entity_id
                     WHERE legal_entity_id IS NULL;

                      l_message := 'Updated '||SQL%ROWCOUNT||' rows in table JE_GR_TRNOVR_RULES with legal entity id: '||l_legal_entity_id;
                      fnd_file.put_line(fnd_file.log,l_message);

         ELSE
                      -- IF legal entity id is null.
                      l_message := 'Unable to Update Legal Entities for the table je_gr_trnovr_rules
                         because no Legal Entity was found.';
                      fnd_file.put_line(fnd_file.log,l_message);

                     ROLLBACK;
                     retcode := 2;
                     errbuf  := l_message;

          END IF;

   ELSE

          l_message :=  'Error - Upgrade process could not complete: '||l_msg_data;
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
          retcode := 2;
          errbuf  := l_message;
          RETURN;

   END IF;

END IF;

l_message := 'Upgrade completed successfully.';
fnd_file.put_line(fnd_file.log,l_message);
COMMIT;

EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   l_message := 'Error - Upgrade process could not complete: '||sqlcode||': '||sqlerrm;
   retcode := 2;
   errbuf  := l_message;
   fnd_file.put_line(fnd_file.log, l_message);

END upgrade_main;

END je_gr_trnovr_rules_upgrade;


/
