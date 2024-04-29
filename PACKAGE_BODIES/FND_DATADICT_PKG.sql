--------------------------------------------------------
--  DDL for Package Body FND_DATADICT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DATADICT_PKG" AS
/* $Header: AFUDICTB.pls 120.2 2005/09/22 19:24:51 rsheh ship $ */

PROCEDURE rename_table(p_appl_id       IN number,
                       p_old_tablename IN varchar2,
                       p_new_tablename IN varchar2) IS
  l_numrows   varchar2(50);
  colnames fnd_dictionary_pkg.namearraytyp;
  pkname varchar2(30);
  pkvalue_old fnd_dictionary_pkg.namearraytyp;
  pkvalue_new fnd_dictionary_pkg.namearraytyp;

  ret boolean;
BEGIN

    --
    -- Update AOL dictionary tables for renamed tables
    --     FND_TABLES, FND_DESCRIPTIVE_FLEXS, FND_DOC_SEQUENCE_CATEGORIES
    --
    IF (length(p_new_tablename) > 30 OR
        length(p_old_tablename) > 30) THEN
        raise_application_error(-20001,
                             'Invalid table names : '||p_old_tablename||
                             '->'||p_new_tablename);
    END IF;

/* Bug 4462304 */
/* Comment these following manual updates cause we have API to do that now */
/*
    update fnd_tables
    set   table_name = p_new_tablename
          , user_table_name = p_new_tablename
    where table_name = p_old_tablename
    and   application_id = p_appl_id;

    l_numrows := SQL%ROWCOUNT;

    update fnd_descriptive_flexs
    set   application_table_name = p_new_tablename
    where application_table_name = p_old_tablename
    and   table_application_id = p_appl_id;

    l_numrows := l_numrows||','||SQL%ROWCOUNT;

    update fnd_id_flexs
    set   application_table_name = p_new_tablename
    where application_table_name = p_old_tablename
    and   table_application_id = p_appl_id;

    l_numrows := l_numrows||','||SQL%ROWCOUNT;

    update fnd_doc_sequence_categories
    set   table_name = p_new_tablename
    where table_name = p_old_tablename
    and   application_id = p_appl_id;

    l_numrows := l_numrows||','||SQL%ROWCOUNT;

*/

  /* Start Bug 4462304 */
  colnames(0) := 'APPLICATION_ID';
  colnames(1) := 'TABLE_NAME';
  colnames(1) := null;
  pkvalue_old(0) := p_appl_id;
  pkvalue_old(1) := p_old_tablename;
  pkvalue_old(2) := null;
  pkvalue_new(0) := p_appl_id;
  pkvalue_new(1) := p_new_tablename;
  pkvalue_new(2) := null;

  ret := fnd_dictionary_pkg.updatepkcolumns('FND','FND_TABLES',
                                   colnames, pkvalue_old, pkvalue_new);
  /* End Bug 4462304 */

END;

END;

/
