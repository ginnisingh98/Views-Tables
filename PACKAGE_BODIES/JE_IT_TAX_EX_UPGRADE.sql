--------------------------------------------------------
--  DDL for Package Body JE_IT_TAX_EX_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IT_TAX_EX_UPGRADE" AS
/* $Header: jeitupgb.pls 120.0 2006/05/19 17:43:46 snama noship $ */

PROCEDURE upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number,
                        p_set_of_books_id IN number,
                        p_legal_entity_id  IN number) IS

l_message VARCHAR2(1000);
l_row_count NUMBER := 0;

BEGIN

fnd_file.put_line(fnd_file.log, 'Input parameters:');
fnd_file.put_line(fnd_file.log, 'Set of Books ID: '||p_set_of_books_id );
fnd_file.put_line(fnd_file.log, 'Legal Entity ID: '||p_legal_entity_id);

retcode := 0;
errbuf := NULL;


-- Update Legal Entity for je_it_year_ex_limit and je_it_exempt_letters tables.
IF (p_legal_entity_id IS NOT NULL) THEN

    UPDATE je_it_year_ex_limit
    SET    legal_entity_id = p_legal_entity_id
    WHERE  set_of_books_id = p_set_of_books_id
    AND    legal_entity_id IS NULL;

    l_message := 'Updated '||SQL%ROWCOUNT||' rows in table je_it_year_ex_limit with
                  legal entity id: '||p_legal_entity_id||
                ' for set of books id: '||p_set_of_books_id;
    fnd_file.put_line(fnd_file.log,l_message);

    UPDATE je_it_exempt_letters
    SET    legal_entity_id = p_legal_entity_id
    WHERE  set_of_books_id = p_set_of_books_id
    AND    legal_entity_id IS NULL;

    l_message := 'Updated '||SQL%ROWCOUNT||' rows in table je_it_exempt_letters with
                  legal entity id: '||p_legal_entity_id||
                ' for set of books id: '||p_set_of_books_id;
    fnd_file.put_line(fnd_file.log,l_message);

 ELSE

    l_message := 'Legal Entity ID is not provided.  Please provide Legal Entity ID for this upgrade.';
    fnd_file.put_line(fnd_file.log,l_message);

    ROLLBACK;
    retcode := 2;
    errbuf  := l_message;
END IF;

IF retcode = 0 THEN
    l_message := 'Upgrade completed successfully.';
    fnd_file.put_line(fnd_file.log,l_message);
    COMMIT;
END IF;

EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   l_message := sqlcode||': '||sqlerrm;
   retcode := 2;
   errbuf  := l_message;
   fnd_file.put_line(fnd_file.log, l_message);

END upgrade_main;

END je_it_tax_ex_upgrade;


/
