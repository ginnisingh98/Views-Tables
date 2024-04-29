--------------------------------------------------------
--  DDL for Package Body PER_DTR_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DTR_CHK_PKG" AS
/* $Header: pedtrchk.pkb 120.0 2006/06/26 15:35:08 debhatta noship $ */

type t_numbers is table of number index by binary_integer;
g_element_type_ids	t_numbers;

PROCEDURE GHR_ELT_BEN_CONV(p_result OUT nocopy varchar2) IS

     GHR_APPLICATION_ID constant   number:=8301;
     GHR_STATUS_INSTALLED constant varchar2(2):='I';

     cursor csr_ghr_installed is
     select status
     from fnd_product_installations
     where application_id = GHR_APPLICATION_ID;

     l_installed fnd_product_installations.status%type;
     l_result varchar2(10) ;

BEGIN
    l_result := 'FALSE';
    open csr_ghr_installed;
    fetch csr_ghr_installed into l_installed;
    if ( l_installed = GHR_STATUS_INSTALLED ) then
      l_result := 'TRUE';
    end if;
    close csr_ghr_installed;

    p_result  := l_result;
   --
END GHR_ELT_BEN_CONV;


PROCEDURE HRAPLUPD1(p_result OUT nocopy varchar2) IS
  l_result varchar2(10);
BEGIN
   l_result := hr_update_utility.isUpdateComplete
      (p_app_shortname      => 'PER'
      ,p_function_name      => null
      ,p_business_group_id  => null
      ,p_update_name        => 'HRAPLUPD1');
   --
   if l_result = 'FALSE' then
      p_result := 'TRUE';
   else
     p_result := 'FALSE';
   end if;
   --
END HRAPLUPD1;

procedure bencwbmu(p_result out nocopy varchar2) is

   cursor c_cwb_setup is
    select 'TRUE'
    from   ben_ler_f
    where  typ_cd = 'COMP';

begin
  p_result := 'FALSE';

  open  c_cwb_setup;
  fetch c_cwb_setup into p_result;
  close c_cwb_setup;

end bencwbmu;

END per_dtr_chk_pkg;

/
