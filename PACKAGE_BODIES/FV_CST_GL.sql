--------------------------------------------------------
--  DDL for Package Body FV_CST_GL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CST_GL" as
    -- $Header: FVCSTGLB.pls 115.5 2003/12/17 21:19:58 ksriniva noship $
-- ==============================================================
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_CST_GL.';
procedure CORRECT_GL_INTERFACE_ENTRIES (
		p_group_id        in  number,
		p_Receipt_id    	in  number,
		p_Deliver_id    	in  number)
--          Purpose of procedure
--
--          Given group id, rcv transaction id 1, rcv transaction id 2
--          select rows from gl interface with that batch id and a reference25
--          of transaction id 1 or 2 (receive or deliver) and an actual_flag
--          of 'A' (don't want to process encumbrance entries) delete two rows
--          with the same value in code_combination_id, one DR and one CR.
--          If more or less than  4 rows found, throw an exception
IS
  l_module_name VARCHAR2(200) := g_module_name || 'CORRECT_GL_INTERFACE_ENTRIES';
  l_errbuf      VARCHAR2(1024);
  temp_count number;
  profile_value varchar2(1);
BEGIN

fnd_profile.get('FV_POST_DETAIL_REC_ACCOUNTING',profile_value);

if profile_value = 'N' then

    select count('should be exactly four rows')
    into temp_count
    from gl_interface
    where reference25 IN (to_char(p_Receipt_id),to_char(p_Deliver_id))
    and group_id = p_group_id
    and actual_flag = 'A';

    if (temp_count) = 4 then
        delete
        from gl_interface
        where group_id = p_group_id
        and reference25 IN (to_char(p_Receipt_id),to_char(p_Deliver_id))
        and actual_flag = 'A'
        and code_combination_id = (
            select code_combination_id
            from gl_interface
            where reference25 IN (to_char(p_Receipt_id),to_char(p_Deliver_id))
            and group_id = p_group_id
            and actual_flag = 'A'
            group by code_combination_id
            having count(code_combination_id) = 2);
    else
        -- we have a problem....
     null;
    end if;

else
-- all lines to be posted to GL don't remove any
   null;
end if;

EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception1',l_errbuf);
    RAISE;
END;

End  FV_CST_GL;

/
