--------------------------------------------------------
--  DDL for Package Body PER_EMPDIR_ORGS_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EMPDIR_ORGS_OVERRIDE" AS
/* $Header: peredcor.pkb 115.1 2003/08/03 12:09 smallina noship $ */

g_override_flg BOOLEAN:= FALSE;

FUNCTION isOverrideEnabled RETURN BOOLEAN IS
BEGIN
    RETURN g_override_flg;
END isOverrideEnabled;

PROCEDURE before_dml(
        errbuf  OUT NOCOPY VARCHAR2
       ,retcode OUT NOCOPY VARCHAR2
       ,p_eff_date IN DATE
       ,p_cnt IN NUMBER
       ,p_rec_locator IN NUMBER
       ,p_srcSystem IN VARCHAR2) IS
BEGIN

      -- Sample Code
     /* IF p_srcSystem = 'PER' THEN
      IF per_empdir_ss.orgTbl.attribute2(p_rec_locator) IS NOT NULL THEN
          per_empdir_ss.swap(per_empdir_ss.orgTbl.name(p_rec_locator)
              ,per_empdir_ss.orgTbl.attribute2(p_rec_locator));
      END IF;
     END IF; */

     NULL;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1, 'Error in before_dml orgs : '||SQLCODE);
        per_empdir_ss.write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END before_dml;
END PER_EMPDIR_ORGS_OVERRIDE;

/
