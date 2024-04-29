--------------------------------------------------------
--  DDL for Package Body SOA_REMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SOA_REMOVE" as
/* $Header: SOAREMB.pls 120.0.12010000.1 2009/04/17 05:51:34 snalagan noship $ */

G_NO_ERROR      pls_integer := 0;          -- success without any error.
G_WARNING       pls_integer := 1;          -- generic warning.


--PROCEDURE

procedure remove_class_derived_entry (
	                             p_base_class_id in pls_integer,
                                     p_err_code OUT NOCOPY pls_integer,
	                             p_err_message OUT NOCOPY varchar2
                                     ) IS

         c_irep_base_name fnd_irep_classes .irep_name%type;

         cursor c_derived_class_entry(c_irep_name in fnd_irep_classes .irep_name%type , c_base_class_id in number) is
          select class_id,class_type from fnd_irep_classes where irep_name = c_irep_name and class_id <> c_base_class_id ;

          cursor c_derived_class_entry1(c_irep_name in fnd_irep_classes .irep_name%type , c_base_class_id in number) is
          select count(*) l_count from fnd_irep_classes where irep_name = c_irep_name and class_id <> c_base_class_id ;
          c_class_rec c_derived_class_entry1%ROWTYPE;
          d_count pls_integer:= -1;


        begin
          if (p_base_class_id is null ) then
		p_err_code := -1;
		wf_core.token('BaseClassId',p_base_class_id);
  		p_err_message := wf_core.translate('WF_WS_BASE_CLASS_NOT_EXIST');
		raise program_exit;
          end if;

          select irep_name into c_irep_base_name from fnd_irep_classes where class_id = p_base_class_id;

          open c_derived_class_entry1(c_irep_base_name,p_base_class_id);
          fetch c_derived_class_entry1 into c_class_rec;
          close c_derived_class_entry1;

         if c_class_rec.l_count = 0 then
          	p_err_code := -1;
  		wf_core.token('BaseClassId',p_base_class_id);
  		p_err_message := wf_core.translate('WF_WS_DERIVED_CLASS_NOT_EXIST');
  		raise program_exit;
  	end if;


          d_count := c_class_rec.l_count;
          FOR c_derived_class_entry_rec1 IN c_derived_class_entry(c_irep_base_name,p_base_class_id)
          LOOP

            if (c_derived_class_entry_rec1.class_type = 'SOAPSERVICEDOC'  OR  c_derived_class_entry_rec1.class_type = 'WEBSERVICEDOC') then
              remove_derived_function_entry(c_derived_class_entry_rec1.class_id,p_err_code ,p_err_message );
            end if;

           begin
             delete from fnd_irep_classes where class_id = c_derived_class_entry_rec1.class_id;
             --dbms_output.put_line('classId to delete' || c_derived_class_entry_rec1.class_id);
            exception
 		when program_exit then
 			raise program_exit;
 		when others then
 			p_err_code := -1;
 			wf_core.token('BaseClassId',p_base_class_id);
                        wf_core.token('DerivedClassId',c_derived_class_entry_rec1.class_id);
 			wf_core.token('SqlErr',SQLERRM);
 			p_err_message := wf_core.translate('WF_WS_CLASS_FUNC_ITER');
 			raise program_exit;
 		end;

              d_count := d_count-1;
        END LOOP;
        if(d_count = 0) then
        p_err_code := 0;
        wf_core.token('BaseClassId',p_base_class_id);
        p_err_message := wf_core.translate('WF_WS_DELETE_SUCCESS');
        end if;

          exception
 		when program_exit then
 			null;
 		when others then
                      p_err_code := -1;
                      p_err_message := wf_core.translate('WF_WS_CLASS_REMOVE');


end remove_class_derived_entry;

--PROCEDURE

procedure remove_derived_function_entry(
                                        p_derived_class_id in pls_integer,
                                        p_err_code OUT NOCOPY pls_integer,
                                        p_err_message OUT NOCOPY varchar2
                                        ) IS

        cursor c_derived_function_entry(c_derived_class_id in number) is
 	select function_id  from fnd_form_functions where irep_class_id = c_derived_class_id;

        cursor c_derived_function_entry1(c_derived_class_id in number) is
 	select COUNT(*) l_count from fnd_form_functions where irep_class_id = c_derived_class_id;
        c_function_rec c_derived_function_entry1%ROWTYPE;
        f_count pls_integer := -1;
        begin

        if (p_derived_class_id is null ) then
		p_err_code := -1;
		wf_core.token('DerivedClassId',p_derived_class_id);
  		p_err_message := wf_core.translate('WF_WS_DERIVED_CLASS_NOT_EXIST');
		raise program_exit;
          end if;

        open c_derived_function_entry1(p_derived_class_id);
        fetch c_derived_function_entry1 into c_function_rec;
        close c_derived_function_entry1;

         if c_function_rec.l_count = 0 then
          	p_err_code := -1;
  		p_err_message := wf_core.translate('WF_WS_DERIVED_FUNC_NOT_EXIST');
  		raise program_exit;
        end if;
        f_count := c_function_rec.l_count;

        FOR c_derived_function_entry_rec IN c_derived_function_entry(p_derived_class_id)
        LOOP

             if(c_derived_function_entry_rec.function_id is null) then

               p_err_code := -1;
               p_err_message := wf_core.translate('WF_WS_BASE_FUNC_NOT_EXIST');
               raise program_exit;
             end if;
               remove_function_lang_entries(c_derived_function_entry_rec.function_id ,p_derived_class_id ,p_err_code ,p_err_message );
               --dbms_output.put_line('functionId to delete' || c_derived_function_entry_rec.function_id );
               delete from fnd_form_functions where function_id = c_derived_function_entry_rec.function_id;
               f_count  := f_count -1;
        END LOOP;
        if(f_count = 0) then
        p_err_code := 0;
 	p_err_message := wf_core.translate('WF_WS_DELETE_SUCCESS');
        end if;

        exception
 		when program_exit then
 			raise program_exit;
 		when others then
                      p_err_code := -1;
                      p_err_message := wf_core.translate('WF_WS_FUNCTION_REMOVE');

end remove_derived_function_entry;

--PROCEDURE

procedure remove_function_lang_entries(
                                       p_derived_function_id in pls_integer,
                                       p_derived_class_id in pls_integer,
                                       p_err_code OUT NOCOPY pls_integer,
	                               p_err_message OUT NOCOPY varchar2
                                      ) IS

  cursor c_derived_function_tl(c_derived_function_id in pls_integer) is
	select *
	from fnd_form_functions_tl
	where function_id = c_derived_function_id;

  begin

     if ( p_derived_function_id is null  ) then
 		p_err_code := -1;
 		p_err_message := 'Base Function ID or Function ID is null';
 		raise program_exit;
     end if ;
    /*FOR c_derived_function_tl_rec IN c_derived_function_tl(p_derived_function_id)
     LOOP
      dbms_output.put_line(c_derived_function_tl_rec.language);
     END LOOP;*/
    remove_class_lang_entry(p_derived_class_id,p_err_code,p_err_message);
    delete from fnd_form_functions_tl where function_id = p_derived_function_id;
    p_err_code := 0;
    p_err_message := wf_core.translate('WF_WS_DELETE_SUCCESS');

exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('DerivedFunctionId',p_derived_function_id);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_FUNC_LANG_REMOVE');



end remove_function_lang_entries;

-- PROCEDURE

procedure remove_class_lang_entry(
                                  p_derived_class_id in pls_integer,
                                  p_err_code OUT NOCOPY pls_integer,
                                  p_err_message OUT NOCOPY varchar2
                                  ) IS

   cursor c_derived_class_tl(c_derived_class_id in pls_integer) is
 	select *
 	from fnd_irep_classes_tl
 	where class_id = c_derived_class_id  ;

   begin
    if (p_derived_class_id is null) then
          p_err_code := -1;
          p_err_message := 'Base Class ID or Class ID is null';
          raise program_exit;
    end if;

   /* FOR c_derived_class_tl_rec IN c_derived_class_tl(p_derived_class_id)
    LOOP
        dbms_output.put_line(c_derived_class_tl_rec.language);
    END LOOP;*/
    delete  from fnd_irep_classes_tl where class_id = p_derived_class_id  ;
    p_err_code := 0;
    p_err_message := wf_core.translate('WF_WS_DELETE_SUCCESS');
exception
  when program_exit then
	raise program_exit;
  when others then
	p_err_code := -1;
        wf_core.token('DerivedClassId',p_derived_class_id);
        wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CLASS_LANG_REMOVE');



end remove_class_lang_entry ;

end SOA_REMOVE;

/
