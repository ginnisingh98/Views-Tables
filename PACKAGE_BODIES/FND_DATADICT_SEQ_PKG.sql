--------------------------------------------------------
--  DDL for Package Body FND_DATADICT_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DATADICT_SEQ_PKG" AS
/* $Header: AFSDICTB.pls 115.2 99/07/16 23:30:29 porting ship  $ */

PROCEDURE rename_seq(p_appl_id       IN number,
                     p_old_seqname IN varchar2,
                     p_new_seqname IN varchar2) IS
  l_numrows   varchar2(50);
BEGIN

    --
    -- Update AOL dictionary tables for renamed sequences
    --     FND_SEQUENCES
    --
    IF (length(p_new_seqname) > 30 OR
        length(p_old_seqname) > 30) THEN
        raise_application_error(-20001,
                             'Invalid sequence names : '||p_old_seqname||
                             '->'||p_new_seqname);
    END IF;

    update fnd_sequences
    set   sequence_name = p_new_seqname
    where sequence_name = p_old_seqname
    and   application_id = p_appl_id;

    l_numrows := SQL%ROWCOUNT;

END;

END;

/
