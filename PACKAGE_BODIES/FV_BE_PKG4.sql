--------------------------------------------------------
--  DDL for Package Body FV_BE_PKG4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_PKG4" as
-- $Header: FVBEPG3B.pls 120.7 2005/07/12 22:14:54 snama ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_BE_PKG4.';

PROCEDURE re_seq_budget_levels (
					x_error_code OUT NOCOPY number,
					x_set_of_books_id IN number)
 IS
   l_module_name VARCHAR2(200) := g_module_name || 're_seq_budget_levels';
   l_errbuf      VARCHAR2(1024);
    v_sequence           number := 1;

    CURSOR C IS
      SELECT BUDGET_LEVEL_NUM, POST_FLAG
      FROM FV_BUDGET_LEVELS
      WHERE FV_BUDGET_LEVELS.SET_OF_BOOKS_ID = x_set_of_books_id
      ORDER BY BUDGET_LEVEL_NUM
      FOR UPDATE OF BUDGET_LEVEL_ID;

    v_budget_level_num  FV_BUDGET_LEVELS.BUDGET_LEVEL_NUM%TYPE;
    v_post_flag FV_BUDGET_LEVELS.POST_FLAG%TYPE;
  BEGIN

    OPEN C;
    LOOP
      -- FETCH THE NEXT BUGET_LEVEL_NUM
      FETCH C INTO v_budget_level_num, v_post_flag;

      -- EXIT LOOP WHEN THERE ARE NO MORE ROWS TO FETCH
      EXIT WHEN C%notfound;

      UPDATE FV_BUDGET_LEVELS
        SET BUDGET_LEVEL_ID =  v_sequence,
            POST_FLAG = DECODE(v_sequence, 1, 'Y', 2, 'Y', v_post_flag)
        WHERE CURRENT OF C;

      v_sequence := v_sequence + 1;
    END LOOP;
    COMMIT;

    CLOSE C;

    x_error_code := -1;
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
  END re_seq_budget_levels;
--------------------------------------------------------------------


 procedure get_budget_description (x_budget_level_id in number,
				   x_set_of_bks_id   in number,
   				   x_description  OUT NOCOPY varchar2,
				   x_error_code   OUT NOCOPY number)
 is
   l_module_name VARCHAR2(200) := g_module_name || 'get_budget_description';
   l_errbuf      VARCHAR2(1024);

 begin

      select  description
	into    x_description
	from    fv_budget_levels
	where budget_level_id = x_budget_level_id
	and   set_of_books_id = x_set_of_bks_id ;

      exception
      when no_data_found then
      l_errbuf := SQLERRM;
      x_error_code := -1;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data',l_errbuf);

    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
 End get_budget_description;
---------------------------------------------------------------

procedure get_trans_description(x_transaction_type    in varchar2,
                                x_set_of_bks_id       in number,
                                x_trans_description   OUT NOCOPY varchar2,
                                x_error_code          OUT NOCOPY number)
 is
   l_module_name VARCHAR2(200) := g_module_name || 'get_trans_description';
   l_errbuf      VARCHAR2(1024);
       begin
               select   description
               into     x_trans_description
               from     fv_be_transaction_types
               where    apprn_transaction_type = x_transaction_type
               and      set_of_books_id        = x_set_of_bks_id;

         exception
         when no_data_found then
         x_error_code := -1;

    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
end get_trans_description;


----------------------------------------------------------------
procedure get_user_name (x_error_code OUT NOCOPY number,
				 x_user_name OUT NOCOPY varchar2,
				 x_user_id		IN	number)
is
   l_module_name VARCHAR2(200) := g_module_name || 'get_user_name';
   l_errbuf      VARCHAR2(1024);

begin
	SELECT USER_NAME
      INTO x_user_name
      FROM FND_USER
      WHERE FND_USER.USER_ID = x_user_id;

      exception
      when no_data_found then
      x_error_code := -1;

    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
End get_user_name;
----------------------------------------------------------------

procedure get_resource_type_desc (x_resource_type 	 IN varchar2,
						x_lookup_type 	 IN varchar2,
						x_description	 OUT NOCOPY varchar2,
						x_error_code	 OUT NOCOPY number)
is
   l_module_name VARCHAR2(200) := g_module_name || 'get_resource_type_desc';
   l_errbuf      VARCHAR2(1024);

begin
	select description
	into x_description
	from fv_lookup_codes
	where lookup_code = x_resource_type and
		lookup_type = x_lookup_type;
      exception
      when no_data_found then
      x_error_code := -1;

    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
      RAISE;
end get_resource_type_desc;
----------------------------------------------------------------
procedure create_journal_category  (P_SET_OF_BKS_ID IN  NUMBER,
                                 P_ERR_CODE      OUT NOCOPY NUMBER) IS
   l_module_name VARCHAR2(200) := g_module_name || 'create_journal_category';
   l_errbuf      VARCHAR2(1024);

CURSOR je_category_cur IS
  select fvbl.description
  from fv_budget_levels fvbl
  where fvbl.set_of_books_id = P_SET_OF_BKS_ID
  and not exists (
                select glc.je_category_name
		from gl_je_categories glc
		where glc.je_category_name = fvbl.description);
begin

  FOR je_category_cur_rec IN je_category_cur LOOP

    gl_je_categories_pkg.load_row(je_category_cur_rec.description,
			         NULL,
			         je_category_cur_rec.description,
			         je_category_cur_rec.description,
			         NULL,
			         NULL,
			         NULL,
			         NULL,
			         NULL,
			         NULL,
			         'SEED',
			         NULL);

  END LOOP;
  commit;

  EXCEPTION
    when others then
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    close je_category_cur;
    p_err_code := -1;


END;

End fv_be_pkg4 ;

/
