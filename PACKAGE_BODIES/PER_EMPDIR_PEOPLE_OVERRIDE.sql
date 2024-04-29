--------------------------------------------------------
--  DDL for Package Body PER_EMPDIR_PEOPLE_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EMPDIR_PEOPLE_OVERRIDE" AS
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
      per_empdir_ss.personTbl.person_key(p_rec_locator) :=
           upper(per_empdir_ss.personTbl.attribute26(p_rec_locator))
           ||'%'||per_empdir_ss.personTbl.person_key(p_rec_locator);
      per_empdir_ss.personTbl.user_name(p_rec_locator) :=
                      upper(per_empdir_ss.personTbl.attribute26(p_rec_locator));
    END IF; */

    NULL;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        per_empdir_ss.write_log(1, 'Error in before_dml people : '||SQLCODE);
        per_empdir_ss.write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END before_dml;
END PER_EMPDIR_PEOPLE_OVERRIDE;

/
