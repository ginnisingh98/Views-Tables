--------------------------------------------------------
--  DDL for Package Body POR_R12_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_R12_UPGRADE_PVT" AS
/* $Header: PORV12UB.pls 120.1 2006/07/14 23:20:07 dkfchan noship $*/

PROCEDURE upgrade_por_profiles IS

  l_continue boolean;
  l_batchsize number := 1000;

  l_old_ovr_requester_profile_id number;
  l_new_ovr_requester_profile_id number;

  l_old_ovr_location_profile_id number;
  l_new_ovr_location_profile_id number;

  l_old_days_need_by_profile_id number;
  l_new_days_need_by_profile_id number;

  l_new_def_exist boolean := false;

BEGIN

  begin

    select profile_option_id
      into l_old_ovr_requester_profile_id
      from fnd_profile_options
     where profile_option_name = 'ICX_REQ_OVERRIDE_REQUESTOR_CODE';

    select profile_option_id
      into l_new_ovr_requester_profile_id
      from fnd_profile_options
     where profile_option_name = 'POR_OVERRIDE_REQUESTER';

    select profile_option_id
      into l_old_ovr_location_profile_id
      from fnd_profile_options
     where profile_option_name = 'ICX_REQ_OVERRIDE_LOCATION_FLAG';

    select profile_option_id
      into l_new_ovr_location_profile_id
      from fnd_profile_options
     where profile_option_name = 'POR_OVERRIDE_LOCATION';

    select profile_option_id
      into l_old_days_need_by_profile_id
      from fnd_profile_options
     where profile_option_name = 'ICX_DAYS_NEEDED_BY';

    select profile_option_id
      into l_new_days_need_by_profile_id
      from fnd_profile_options
     where profile_option_name = 'POR_DAYS_NEEDED_BY';

    l_new_def_exist := true;

  exception

    when others then
      l_new_def_exist := false;

  end;

  if (l_new_def_exist) then

    l_continue := TRUE;

    -- Update non site level profile values

    WHILE(l_continue) LOOP

        update fnd_profile_option_values v1
           set v1.profile_option_id = decode(v1.profile_option_id,
                                             l_old_ovr_requester_profile_id,
                                             l_new_ovr_requester_profile_id,
                                             l_old_ovr_location_profile_id,
                                             l_new_ovr_location_profile_id,
                                             l_old_days_need_by_profile_id,
                                             l_new_days_need_by_profile_id, -1)
         where v1.profile_option_id in (l_old_ovr_requester_profile_id,
                                        l_old_ovr_location_profile_id,
                                        l_old_days_need_by_profile_id)
           and v1.level_id <> 10001
           and not exists (select 1
                             from fnd_profile_option_values v2
                            where v2.profile_option_id =
                                decode(v1.profile_option_id,
                                       l_old_ovr_requester_profile_id,
                                       l_new_ovr_requester_profile_id,
                                       l_old_ovr_location_profile_id,
                                       l_new_ovr_location_profile_id,
                                       l_old_days_need_by_profile_id,
                                       l_new_days_need_by_profile_id, -1)
                              and v2.level_id = v1.level_id
                              and v2.level_value = v1.level_value)
           and rownum <= l_batchsize;

         IF (SQL%ROWCOUNT < l_batchsize) THEN
           l_continue := FALSE;
         END IF;

         COMMIT;

    END LOOP;

    -- Update site level profile value

    update fnd_profile_option_values p1
       set p1.profile_option_value =
           (select p2.profile_option_value
              from fnd_profile_option_values p2
             where p2.profile_option_id = decode(p1.profile_option_id,
                                             l_new_ovr_requester_profile_id,
                                             l_old_ovr_requester_profile_id,
                                             l_new_ovr_location_profile_id,
                                             l_old_ovr_location_profile_id,
                                             l_new_days_need_by_profile_id,
                                             l_old_days_need_by_profile_id, -1)
               and p2.level_id = 10001)
     where p1.profile_option_id in (l_new_ovr_requester_profile_id,
                                    l_new_ovr_location_profile_id,
                                    l_new_days_need_by_profile_id)
       and p1.level_id = 10001;

    COMMIT;

  end if;

END upgrade_por_profiles;

END POR_R12_UPGRADE_PVT;

/
