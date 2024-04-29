--------------------------------------------------------
--  DDL for Package Body BEN_CMP_USR_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMP_USR_HOOKS" as
/* $Header: benusrhk.pkb 120.0 2005/05/28 09:33:59 appldev noship $*/

procedure cmp_uncompiled is
--
cursor c1 is
    select object_name from user_objects
    where status='INVALID'
        and ( object_name like 'BEN%BK1' or object_name like 'BEN%RKU'
        or object_name like 'BEN%BK2' or object_name like 'BEN%RKI'
        or object_name like 'BEN%BK3' or object_name like 'BEN%RKD' );
l_name varchar2(100);
--
begin
    open c1;
    loop
        fetch c1 into l_name;
        exit when c1%notfound;
        hr_api_user_hooks.create_package_body(l_name);
    end loop;
end cmp_uncompiled;

end ben_cmp_usr_hooks;

/
