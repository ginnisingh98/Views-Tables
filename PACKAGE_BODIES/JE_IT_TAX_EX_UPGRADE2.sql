--------------------------------------------------------
--  DDL for Package Body JE_IT_TAX_EX_UPGRADE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IT_TAX_EX_UPGRADE2" AS
/* $Header: jeitup2b.pls 120.1 2006/07/29 00:05:05 akwu noship $  */

PROCEDURE upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number
                        ) IS


l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
l_return_status varchar2(10);

l_message VARCHAR2(1000);
l_org_id NUMBER(15);
l_legal_entity_id NUMBER;

BEGIN

retcode := 0;
errbuf := NULL;

-- Get the profile org id.
l_org_id := FND_PROFILE.VALUE('ORG_ID');
IF l_org_id IS NOT NULL THEN

    fnd_file.put_line(fnd_file.log, 'Org id: '||l_org_id);

--commented for bug 5408438
--    xle_upgrade_utils.get_default_legal_context(x_return_status => l_return_status,
--						x_msg_count => l_msg_count,
--						x_msg_data  => l_msg_data,
--						p_org_id => l_org_id,
--						x_dlc    => l_legal_entity_id);

    BEGIN
     SELECT default_legal_context_id
     INTO l_legal_entity_id
     FROM hr_operating_units
     WHERE organization_id = l_org_id;
    EXCEPTION
    When others then
     l_return_status := 'E';
     l_msg_data := SQLERRM;
    END;

    fnd_file.put_line(fnd_file.log, 'Ret Status: '||l_return_status);
    fnd_file.put_line(fnd_file.log, 'Msg Data: '||l_msg_data);

    -- If the return status is not error, then continue with the process
    IF l_return_status IS NULL THEN

         IF l_legal_entity_id IS NOT NULL THEN

       	UPDATE je_it_exlet_seqs
      	SET    legal_entity_id = l_legal_entity_id
      	WHERE  legal_entity_id IS NULL;

      	l_message := 'Updated '||SQL%ROWCOUNT||' records in je_it_exlet_seqs with legal entity id: '
                    ||l_legal_entity_id;
      	FND_FILE.PUT_LINE(FND_FILE.LOG,l_message);

          ELSE
      	-- IF legal entity id is null.
      	l_message := 'Unable to Update Legal Entities for the tables je_it_exlet_seqs
                         because no Legal Entity was found.';
      	FND_FILE.PUT_LINE( FND_FILE.LOG,l_message);
      	retcode := 2;
      	errbuf  := l_message;
		RETURN;
   	   END IF;

     ELSE   -- If return status is Error

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

END je_it_tax_ex_upgrade2;


/
