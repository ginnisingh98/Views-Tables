--------------------------------------------------------
--  DDL for Package Body PAY_MLS_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MLS_TRIGGERS" AS
/* $Header: pymlstrg.pkb 120.0.12000000.2 2007/03/27 06:04:13 ckesanap noship $ */

  procedure pur_ari ( p_user_row_id                in pay_user_rows_f.user_row_id%type,
                         p_row_low_range_or_name_n    in pay_user_rows_f.row_low_range_or_name%type,
                         p_row_low_range_or_name_o    in pay_user_rows_f.row_low_range_or_name%type)  IS

    l_proc varchar2(30) ;
    l_count binary_integer;

  begin

    l_proc  := 'pur_ari' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count:=  l_pur.count();

    l_pur(l_count+1).user_row_id                := p_user_row_id;
    l_pur(l_count+1).row_low_range_or_name_n    := p_row_low_range_or_name_n;
    l_pur(l_count+1).row_low_range_or_name_o    := p_row_low_range_or_name_o;


    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;


  procedure pur_brd ( p_user_row_id in pay_user_rows_f.user_row_id%type ) IS
   l_proc varchar2(30) ;

   l_count binary_integer;

  begin

   l_proc  := 'pur_brd' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count:= l_pur.count;
    l_pur_del(l_count+1) := p_user_row_id ;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;

  end;


  procedure pur_asi IS
   l_proc varchar2(30) ;

   cursor c_pur ( p_user_row_id pay_user_rows_f.user_row_id%type)
          is
    select 1
      from pay_user_rows_f b
     where b.user_row_id = p_user_row_id
        and not exists
         -- this is the first insert ; there is no corresponding row in tl table
         ( select 1
              from pay_user_rows_f_tl tl
            where tl.user_row_id = p_user_row_id ) ;
     rec_pur c_pur%rowtype;
  begin

    l_proc  := 'pur_asi' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
    for i in 1..l_pur.count loop
      open c_pur(l_pur(i).user_row_id) ;
      fetch c_pur into rec_pur ;
      if c_pur%found then
        pay_urt_ins.ins_tl(P_LANGUAGE_CODE         =>userenv('LANG')
                          ,P_USER_ROW_ID           => l_pur(i).user_row_id
                          ,P_ROW_LOW_RANGE_OR_NAME => l_pur(i).row_low_range_or_name_n ) ;
      end if;
      close c_pur;
    end loop;

    l_pur.delete;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_pur.delete;
     raise;
  end;


  procedure pur_asd IS
   l_proc varchar2(30) := 'pur_asd' ;
   cursor c_pur_del ( p_user_row_id pay_user_rows_f.user_row_id%type )
       is
   select 1
     from pay_user_rows_f_tl p
    where p.user_row_id = p_user_row_id
      and not exists
       ( select 1
           from pay_user_rows_f p1
          where p1.user_row_id = p_user_row_id

        );
    rec_pur c_pur_del%rowtype;

  begin
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
      for i in 1..l_pur_del.count loop
        open c_pur_del(l_pur_del(i)) ;
        fetch c_pur_del into rec_pur ;
          if c_pur_del%found then
            pay_urt_del.del_tl(l_pur_del(i));
          end if;
        close c_pur_del ;
      end loop ;
    l_pur_del.delete;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_pur_del.delete;
     raise;
  end;


  procedure pbc_ari (p_balance_category_id     in pay_balance_categories_f.balance_category_id%type,
                                         p_user_category_name_n  in pay_balance_categories_f.user_category_name%type,
                                         p_user_category_name_o  in pay_balance_categories_f.user_category_name%type) IS
   l_proc varchar2(30)  ;
   l_count binary_integer;

  begin

   l_proc  := 'pbc_ari' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
   l_count:= l_pbc.count ;

   l_pbc(l_count+1).balance_category_id        := p_balance_category_id;
   l_pbc(l_count+1).user_category_name_n       := p_user_category_name_n;
   l_pbc(l_count+1).user_category_name_o       := p_user_category_name_o;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;

  end;


  procedure pbc_brd (p_balance_category_id in pay_balance_categories_f.balance_category_id%type) IS
   l_proc varchar2(30)  ;
   l_count binary_integer;
  begin
    l_proc  := 'pbc_brd' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count :=l_pbc_del.count;
    l_pbc_del( l_count+1 )  :=p_balance_category_id ;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;

  procedure pbc_asi  IS
   l_proc varchar2(30) ;
   cursor c_pbc ( p_balance_category_id pay_balance_categories_f.balance_category_id%type)
          is
    select 1
      from pay_balance_categories_f b
     where b.balance_category_id = p_balance_category_id
        and not exists
         -- this is the first insert ; there is no corresponding row in tl table
         ( select 1
              from pay_balance_categories_f_tl tl
            where tl.balance_category_id = p_balance_category_id ) ;
     rec_pbc c_pbc%rowtype;
  begin
   l_proc  := 'pbc_asi' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
    for i in 1..l_pbc.count loop
      open c_pbc(l_pbc(i).balance_category_id);
      fetch c_pbc into rec_pbc;
      if c_pbc%found then
        pay_tbc_ins.ins_tl(P_LANGUAGE_CODE        =>userenv('LANG')
                          ,P_BALANCE_CATEGORY_ID  =>l_pbc(i).balance_category_id
                          ,P_USER_CATEGORY_NAME   =>l_pbc(i).user_category_name_n);
      end if;
      close c_pbc;
    end loop ;
    l_pbc.delete;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_pbc.delete;
     raise;
  end;


  procedure pbc_asd  IS
   l_proc varchar2(30)  ;
   cursor c_pbc_del ( p_balance_category_id pay_balance_categories_f.balance_category_id%type )
       is
   select 1
     from pay_balance_categories_f_tl p
    where p.balance_category_id = p_balance_category_id
      and not exists
       ( select 1
           from pay_balance_categories_f p1
          where p1.balance_category_id = p_balance_category_id

        );
    rec_pbc c_pbc_del%rowtype;
  begin
    l_proc  := 'pbc_asd' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
      for i in 1..l_pbc_del.count loop
        open c_pbc_del(l_pbc_del(i)) ;
        fetch c_pbc_del into rec_pbc;
          if c_pbc_del%found then
            pay_tbc_del.del_tl( l_pbc_del(i)) ;
          end if ;
        close c_pbc_del;
      end loop ;
    l_pbc_del.delete;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_pbc_del.delete;
     raise;
  end;


  procedure glb_ari ( p_global_id            in ff_globals_f.global_id%type,
                                        p_global_description_o in ff_globals_f.global_description%type,
                                        p_global_description_n in ff_globals_f.global_description%type,
                                        p_global_name_o        in ff_globals_f.global_name%type,
                                       p_global_name_n        in ff_globals_f.global_name%type) IS
   l_proc varchar2(30) := 'glb_ari' ;
   l_count binary_integer;

  begin

    l_proc  := 'glb_ari' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count := l_glb.count;
    l_glb(l_count+1).global_id                    := p_global_id ;
    l_glb(l_count+1).global_description_o := p_global_description_o ;
    l_glb(l_count+1).global_description_n := p_global_description_n ;
    l_glb(l_count+1).global_name_o          := p_global_name_o;
    l_glb(l_count+1).global_name_n          := p_global_name_n;


    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;


  procedure glb_brd (p_global_id             in ff_globals_f.global_id%type) IS
   l_proc varchar2(30) ;
   l_count binary_integer;
  begin

    l_proc  := 'glb_brd' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count := l_glb_del.count;
    l_glb_del(l_count+1) := p_global_id ;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;


  procedure glb_asi  IS
   l_proc varchar2(30) ;
    cursor c_glb ( p_global_id ff_globals_f.global_id%type)
          is
    select 1
      from ff_globals_f b
     where b.global_id = p_global_id
        and not exists
         -- this is the first insert; there is no corresponding row in tl table
         ( select 1
             from ff_globals_f_tl tl
            where tl.global_id = p_global_id ) ;
     rec_glb c_glb%rowtype;
  begin
    l_proc := 'glb_asi' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
      for i in 1..l_glb.count loop
        open c_glb(l_glb(i).global_id) ;
        fetch c_glb into rec_glb ;
        if c_glb%found then
          ff_fgt_ins.ins_tl(  P_LANGUAGE_CODE      => userenv('LANG')
                              ,P_GLOBAL_ID          => l_glb(i).global_id
                              ,P_GLOBAL_NAME        => l_glb(i).global_name_n
                              ,P_GLOBAL_DESCRIPTION => l_glb(i).global_description_n
                            );
        end if;
        close c_glb;
      end loop ;

    l_glb.delete ;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_glb.delete;
     raise;
  end;


  procedure glb_asd  IS
   l_proc varchar2(30) ;
   cursor c_glb_del ( p_global_id ff_globals_f.global_id%type )
       is
   select 1
     from ff_globals_f_tl f
    where f.global_id = p_global_id
      and not exists
       ( select 1
           from ff_globals_f f1
          where f1.global_id = p_global_id

        );
    rec_glb c_glb_del%rowtype;

  begin
   l_proc  := 'glb_asd' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
    hr_utility.set_location('table count -'||l_glb_del.count ,10 ) ;
     for i in 1..l_glb_del.count loop
       open c_glb_del(l_glb_del(i));
       fetch c_glb_del into rec_glb;
       if c_glb_del%found then
         hr_utility.set_location('found -'||l_glb_del(i) ,10 ) ;
         ff_fgt_del.del_tl(l_glb_del(i));
       end if;
       close c_glb_del;
     end loop;

    l_glb_del.delete;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;
  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_glb_del.delete;
     raise;
  end;


  procedure fml_ari ( p_formula_id      in ff_formulas_f.formula_id%type,
                       p_formula_name_o    in ff_formulas_f.formula_name%type,
                       p_formula_name_n    in ff_formulas_f.formula_name%type,
                       p_description_o     in ff_formulas_f.description%type,
                       p_description_n     in ff_formulas_f.description%type) IS
   l_proc varchar2(30) ;
   l_count binary_integer;
  begin
   l_proc  := 'fml_ari' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count := l_fml.count;
    l_fml(l_count+1).formula_id          :=  p_formula_id;
    l_fml(l_count+1).formula_name_o      :=  p_formula_name_o;
    l_fml(l_count+1).formula_name_n      :=  p_formula_name_n;
    l_fml(l_count+1).description_o       :=  p_description_o;
    l_fml(l_count+1).description_n       :=  p_description_n;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;


  procedure fml_brd (p_formula_id       in ff_formulas_f.formula_id%type) IS
   l_proc varchar2(30) ;
   l_count binary_integer;
  begin
    l_proc  := 'fml_brd' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    l_count := l_fml_del.count;
    l_fml_del(l_count+1 ) := p_formula_id ;

    hr_utility.set_location('count   -'||l_count,50 ) ;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;


  procedure fml_asi  IS
   l_proc varchar2(30)  ;
   cursor c_fml (p_formula_id ff_formulas_f.formula_id%type )
       is
   select 1
     from ff_formulas_f b
    where b.formula_id = p_formula_id
      and not exists
       -- this is the first insert ; there is no corresponding row in tl table
       ( select 1
           from ff_formulas_f_tl tl
          where tl.formula_id = p_formula_id ) ;
   rec_fml c_fml%rowtype;
  begin
   l_proc := 'fml_asi' ;

   hr_utility.set_location('Entering -'||l_proc ,05 ) ;
   for i in 1..l_fml.count loop
     open c_fml (l_fml(i).formula_id) ;
     fetch c_fml into rec_fml;
     if c_fml%found then
       ff_fft_ins.ins_tl(  P_LANGUAGE_CODE=>userenv('LANG')
                          ,P_FORMULA_ID   =>l_fml(i).formula_id
                          ,P_FORMULA_NAME =>l_fml(i).formula_name_n
                          ,P_DESCRIPTION  =>l_fml(i).description_n
                         );

     end if;
     close c_fml;
   end loop;

   l_fml.delete;
   hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_fml.delete;
     raise;
  end;



  procedure fml_asd  IS
   l_proc varchar2(30) ;
   cursor c_fml_del ( p_formula_id ff_formulas_f.formula_id%type )
       is
   select 1
     from ff_formulas_f_tl f
    where f.formula_id = p_formula_id
      and not exists
       ( select 1
           from ff_formulas_f f1
          where f1.formula_id = p_formula_id

        );
    rec_fml c_fml_del%rowtype;
  begin
    l_proc := 'fml_asd' ;
    hr_utility.set_location('Entering -'||l_proc ,05 ) ;
    for i in 1..l_fml_del.count loop
     open c_fml_del (l_fml_del(i)) ;
     fetch c_fml_del into rec_fml;
     if c_fml_del%found then
       ff_fft_del.del_tl(  P_FORMULA_ID  =>l_fml_del(i)  );

     end if;
     close c_fml_del;
    end loop ;
    l_fml_del.delete;
    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     l_fml_del.delete;
     raise;
  end;

  ----For Bug:4372098--
  procedure set_dml_status (status in varchar2)  IS

    l_proc varchar2(30) ;

  begin

    l_proc  := 'set_dml_status' ;

    hr_utility.set_location('Entering -'||l_proc ,05 ) ;

    ff_formulas_f_pkg.g_dml_status := hr_general.char_to_bool(status);

    if(status = 'TRUE') then
      hr_general.g_data_migrator_mode := 'Y';
    elsif(status='FALSE') then
      hr_general.g_data_migrator_mode := 'N';
    end if;

    hr_utility.set_location('Leaving  -'||l_proc,50 ) ;

  exception
  when others then
     hr_utility.set_location('Error  -'||substr(sqlerrm,1,150),99 ) ;
     raise;
  end;
  ---

END pay_mls_triggers ;



/
