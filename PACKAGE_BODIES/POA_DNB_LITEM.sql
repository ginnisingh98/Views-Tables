--------------------------------------------------------
--  DDL for Package Body POA_DNB_LITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DNB_LITEM" AS
/* $Header: poalitmb.pls 120.0 2005/06/01 12:37:29 appldev noship $ */


PROCEDURE poa_list_all_items(Errbuf  in out NOCOPY Varchar2,
                             Retcode  in out NOCOPY Varchar2)
IS
  CURSOR c_all_items IS
     SELECT distinct item_number_pk,
         item_name,
         description
     FROM EDW_Item_Item_LTC
     WHERE (CATSET1_Category_FK_Key <> 0);

  v_buf    VARCHAR2(240) := NULL;

BEGIN

  errbuf := NULL;
  Retcode := 0;

  POA_LOG.setup('POAITEMS');
  POA_LOG.debug_line('In List All Items');

  FOR litem in c_all_items LOOP
    POA_LOG.output_line('"' ||
                        litem.item_number_pk || '","' ||
                        litem.item_name || '","' ||
                        litem.description || '"');
  END LOOP;

  POA_LOG.put_line('POAITEMS.out generated');
  POA_LOG.wrapup('SUCCESS');

EXCEPTION WHEN OTHERS THEN
     errbuf := sqlerrm;
     retcode := sqlcode;

     POA_LOG.put_line('Error while listing items:');
     POA_LOG.put_line(sqlcode || ': ' || sqlerrm);

     v_buf := retcode || ':' || errbuf;
     ROLLBACK;
     POA_LOG.put_line(v_buf);
     POA_LOG.wrapup('ERROR');

     RETURN;

END poa_list_all_items;

END POA_DNB_LITEM;


/
