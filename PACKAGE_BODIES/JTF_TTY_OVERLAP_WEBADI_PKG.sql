--------------------------------------------------------
--  DDL for Package Body JTF_TTY_OVERLAP_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_OVERLAP_WEBADI_PKG" AS
/* $Header: jtftyovb.pls 120.3.12010000.3 2008/11/24 10:02:08 gmarwah ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PURPOSE
--
--    Population of interface table for Overlapping Territory Group Report
--
--      Procedures:
--         (see below for specification)
--
--      This package is publicly available for use
--
--    HISTORY
--      08/13/2003    ARPATEL        Created
--      07/08/2008    Gmarwah        Modified to handle 20
--                                   overlapping territories
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

procedure POPULATE_INTERFACE(          p_named_account_id in varchar2,
                                       p_terr_group_id    in varchar2,
                                       p_DUNS             in varchar2,
                                       p_userid           in varchar2,
                                       x_seq             out NOCOPY varchar2
                                       ) IS


l_seq number;
l_TG1 VARCHAR2(360);
l_PARENT1 VARCHAR2(360);
l_TG2 VARCHAR2(360);
l_PARENT2 VARCHAR2(360);
l_TG3 VARCHAR2(360);
l_PARENT3 VARCHAR2(360);
l_TG4 VARCHAR2(360);
l_PARENT4 VARCHAR2(360);
l_TG5 VARCHAR2(360);
l_PARENT5 VARCHAR2(360);
l_TG6 VARCHAR2(360);
l_PARENT6 VARCHAR2(360);
l_TG7 VARCHAR2(360);
l_PARENT7 VARCHAR2(360);
l_TG8 VARCHAR2(360);
l_PARENT8 VARCHAR2(360);
l_TG9 VARCHAR2(360);
l_PARENT9 VARCHAR2(360);
l_TG10 VARCHAR2(360);
l_PARENT10 VARCHAR2(360);
l_TG11 VARCHAR2(360);
l_PARENT11 VARCHAR2(360);
l_TG12 VARCHAR2(360);
l_PARENT12 VARCHAR2(360);
l_TG13 VARCHAR2(360);
l_PARENT13 VARCHAR2(360);
l_TG14 VARCHAR2(360);
l_PARENT14 VARCHAR2(360);
l_TG15 VARCHAR2(360);
l_PARENT15 VARCHAR2(360);
l_TG16 VARCHAR2(360);
l_PARENT16 VARCHAR2(360);
l_TG17 VARCHAR2(360);
l_PARENT17 VARCHAR2(360);
l_TG18 VARCHAR2(360);
l_PARENT18 VARCHAR2(360);
l_TG19 VARCHAR2(360);
l_PARENT19 VARCHAR2(360);
l_TG20 VARCHAR2(360);
l_PARENT20 VARCHAR2(360);

cursor c_NA_in_TG is
select distinct  named_account_id
  from jtf_tty_terr_grp_accts
 where terr_group_id = p_terr_group_id;

cursor c_conflicting_TG(c_named_account_id VARCHAR2) is
select distinct TG.terr_group_name
     , TER.name parent_territory
  from jtf_tty_terr_grp_accts TGA
      ,jtf_tty_terr_groups TG
      ,jtf_terr_all TER
 where TGA.named_account_id = c_named_account_id
  and TGA.terr_group_id = TG.terr_group_id
  and TG.parent_terr_id = TER.terr_id
  and trunc(TG.active_from_date) <= trunc(sysdate)
  and trunc(nvl(TG.active_to_date, sysdate)) >= trunc(sysdate) ;

cursor c_NA_for_DUNS is
select distinct named_account_id
  from jtf_tty_named_accts NA
      ,hz_parties HZP
  where HZP.party_id = NA.party_id
    and HZP.duns_number_c = p_DUNS;

 J NUMBER;
BEGIN

    -- remove existing old data for this userid
    delete from JTF_TTY_WEBADI_INTERFACES
    where user_id = to_number(p_userid)
    and sysdate - creation_date >2;

    select jtf_tty_interface_s.nextval into l_seq from dual;
    x_seq := l_seq;

    --process if territory group chosen
    if p_terr_group_id is not null
    then
      --find all named accounts in this territory group
      FOR NA_rec in c_NA_in_TG
      LOOP
        J := 0;
        --populate local variables to show conflicting TG denormalised for each NA
        FOR conflict_TG_rec in c_conflicting_TG(NA_rec.named_Account_id)
        LOOP
          J := J+1;
          --maximum of 20 conflicting TG's allowed in this report
          if J=1 then
          l_TG1 := conflict_TG_rec.terr_group_name;
          l_PARENT1 := conflict_TG_rec.parent_territory;
          end if;

          if J=2 then
          l_TG2 := conflict_TG_rec.terr_group_name;
          l_PARENT2 := conflict_TG_rec.parent_territory;
          end if;

          if J=3 then
          l_TG3 := conflict_TG_rec.terr_group_name;
          l_PARENT3 := conflict_TG_rec.parent_territory;
          end if;

          if J=4 then
          l_TG4 := conflict_TG_rec.terr_group_name;
          l_PARENT4 := conflict_TG_rec.parent_territory;
          end if;

          if J=5 then
          l_TG5 := conflict_TG_rec.terr_group_name;
          l_PARENT5 := conflict_TG_rec.parent_territory;
          end if;

          if J=6 then
          l_TG6 := conflict_TG_rec.terr_group_name;
          l_PARENT6 := conflict_TG_rec.parent_territory;
          end if;

          if J=7 then
          l_TG7 := conflict_TG_rec.terr_group_name;
          l_PARENT7 := conflict_TG_rec.parent_territory;
          end if;

          if J=8 then
          l_TG8 := conflict_TG_rec.terr_group_name;
          l_PARENT8 := conflict_TG_rec.parent_territory;
          end if;

          if J=9 then
          l_TG9 := conflict_TG_rec.terr_group_name;
          l_PARENT9 := conflict_TG_rec.parent_territory;
          end if;

          if J=10 then
          l_TG10 := conflict_TG_rec.terr_group_name;
          l_PARENT10 := conflict_TG_rec.parent_territory;
          end if;

          if J=11 then
          l_TG11 := conflict_TG_rec.terr_group_name;
          l_PARENT11 := conflict_TG_rec.parent_territory;
          end if;

          if J=12 then
          l_TG12 := conflict_TG_rec.terr_group_name;
          l_PARENT12 := conflict_TG_rec.parent_territory;
          end if;

          if J=13 then
          l_TG13 := conflict_TG_rec.terr_group_name;
          l_PARENT13 := conflict_TG_rec.parent_territory;
          end if;

          if J=14 then
          l_TG14 := conflict_TG_rec.terr_group_name;
          l_PARENT14 := conflict_TG_rec.parent_territory;
          end if;

          if J=15 then
          l_TG15 := conflict_TG_rec.terr_group_name;
          l_PARENT15 := conflict_TG_rec.parent_territory;
          end if;

          if J=16 then
          l_TG16 := conflict_TG_rec.terr_group_name;
          l_PARENT16 := conflict_TG_rec.parent_territory;
          end if;

          if J=17 then
          l_TG17 := conflict_TG_rec.terr_group_name;
          l_PARENT17 := conflict_TG_rec.parent_territory;
          end if;

          if J=18 then
          l_TG18 := conflict_TG_rec.terr_group_name;
          l_PARENT18 := conflict_TG_rec.parent_territory;
          end if;

          if J=19 then
          l_TG19 := conflict_TG_rec.terr_group_name;
          l_PARENT19 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          l_TG20 := conflict_TG_rec.terr_group_name;
          l_PARENT20 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          EXIT;
          end if;

        END LOOP;

        --insert record into table, if there the named accountbelongs to more than one territory group
        if J>1 then

        insert into JTF_TTY_WEBADI_INTERFACES
        ( user_sequence
         ,user_id
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,attribute16
         ,attribute17
         ,attribute18
         ,attribute19
         ,attribute20
         ,attribute21
         ,attribute22
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
         ,ATTRIBUTE31
         ,ATTRIBUTE32
         ,ATTRIBUTE33
         ,ATTRIBUTE34
         ,ATTRIBUTE35
         ,ATTRIBUTE36
         ,ATTRIBUTE37
         ,ATTRIBUTE38
         ,ATTRIBUTE39
         ,ATTRIBUTE40
         ,ATTRIBUTE41
         ,ATTRIBUTE42
         ,ATTRIBUTE43
         ,ATTRIBUTE44
         ,ATTRIBUTE45
         ,ATTRIBUTE46
         ,ATTRIBUTE47
         ,ATTRIBUTE48
         ,ATTRIBUTE49
         ,ATTRIBUTE50
         ,ATTRIBUTE51
         ,ATTRIBUTE52
         ,ATTRIBUTE53
         ,ATTRIBUTE54
         ,ATTRIBUTE55

        ) select
           l_seq
         , p_userid
         , HZP.party_name
         , LKP.meaning site_type
         , HZP.party_number
         , HZP.duns_number_c site_duns
         , HZP.known_as trade_name
         , null
         , null
         , null
         , null
         , HZP.city
         , HZP.state
         , HZP.postal_code
         , l_TG1
         , l_PARENT1
         , l_TG2
         , l_PARENT2
         , l_TG3
         , l_PARENT3
         , l_TG4
         , l_PARENT4
         , l_TG5
         , l_PARENT5
         , G_USER
         , SYSDATE
         , G_USER
         , SYSDATE
         , NA.PARTY_SITE_ID
         , l_TG6
         , l_PARENT6
         , l_TG7
         , l_PARENT7
         , l_TG8
         , l_PARENT8
         , l_TG9
         , l_PARENT9
         , l_TG10
         , l_PARENT10
         , l_TG11
         , l_PARENT11
         , l_TG12
         , l_PARENT12
         , l_TG13
         , l_PARENT13
         , l_TG14
         , l_PARENT14
         , l_TG15
         , l_PARENT15
         , l_TG16
         , l_PARENT16
         , l_TG17
         , l_PARENT17
         , l_TG18
         , l_PARENT18
         , l_TG19
         , l_PARENT19
         , l_TG20
         , l_PARENT20
          from
               jtf_tty_named_Accts NA
              ,hz_parties HZP
              ,fnd_lookups LKP
         where NA.named_account_id = NA_rec.named_Account_id
          and NA.party_id = HZP.party_id
          and NA.site_type_code = LKP.lookup_code
          and LKP.lookup_type = 'JTF_TTY_SITE_TYPE_CODE';

        end if;
      l_TG1 :=null;
      l_TG2 :=null;
      l_TG3 :=null;
      l_TG4 :=null;
      l_TG5 :=null;
      l_TG6 :=null;
      l_TG7 :=null;
      l_TG8 :=null;
      l_TG9 :=null;
      l_TG10 :=null;
      l_TG11 :=null;
      l_TG12 :=null;
      l_TG13 :=null;
      l_TG14 :=null;
      l_TG15 :=null;
      l_TG16 :=null;
      l_TG17 :=null;
      l_TG18 :=null;
      l_TG19 :=null;
      l_TG20 :=null;

      l_PARENT1 :=null;
      l_PARENT2 :=null;
      l_PARENT3 :=null;
      l_PARENT4 :=null;
      l_PARENT5 :=null;
      l_PARENT6 :=null;
      l_PARENT7 :=null;
      l_PARENT8 :=null;
      l_PARENT9 :=null;
      l_PARENT10 :=null;
      l_PARENT11 :=null;
      l_PARENT12 :=null;
      l_PARENT13 :=null;
      l_PARENT14 :=null;
      l_PARENT15 :=null;
      l_PARENT16 :=null;
      l_PARENT17 :=null;
      l_PARENT18 :=null;
      l_PARENT19 :=null;
      l_PARENT20 :=null;

      END LOOP;

    elsif p_named_account_id is not null
    then
        J := 0;
        --populate local variables to show conflicting TG denormalised for each NA
        FOR conflict_TG_rec in c_conflicting_TG(p_named_account_id)
        LOOP
          J := J+1;
          --maximum of 5 conflicting TG's allowed in this report
          if J=1 then
          l_TG1 := conflict_TG_rec.terr_group_name;
          l_PARENT1 := conflict_TG_rec.parent_territory;
          end if;

          if J=2 then
          l_TG2 := conflict_TG_rec.terr_group_name;
          l_PARENT2 := conflict_TG_rec.parent_territory;
          end if;

          if J=3 then
          l_TG3 := conflict_TG_rec.terr_group_name;
          l_PARENT3 := conflict_TG_rec.parent_territory;
          end if;

          if J=4 then
          l_TG4 := conflict_TG_rec.terr_group_name;
          l_PARENT4 := conflict_TG_rec.parent_territory;
          end if;

          if J=5 then
          l_TG5 := conflict_TG_rec.terr_group_name;
          l_PARENT5 := conflict_TG_rec.parent_territory;
          end if;

          if J=6 then
          l_TG6 := conflict_TG_rec.terr_group_name;
          l_PARENT6 := conflict_TG_rec.parent_territory;
          end if;

          if J=7 then
          l_TG7 := conflict_TG_rec.terr_group_name;
          l_PARENT7 := conflict_TG_rec.parent_territory;
          end if;

          if J=8 then
          l_TG8 := conflict_TG_rec.terr_group_name;
          l_PARENT8 := conflict_TG_rec.parent_territory;
          end if;

          if J=9 then
          l_TG9 := conflict_TG_rec.terr_group_name;
          l_PARENT9 := conflict_TG_rec.parent_territory;
          end if;

          if J=10 then
          l_TG10 := conflict_TG_rec.terr_group_name;
          l_PARENT10 := conflict_TG_rec.parent_territory;
          end if;

          if J=11 then
          l_TG11 := conflict_TG_rec.terr_group_name;
          l_PARENT11 := conflict_TG_rec.parent_territory;
          end if;

          if J=12 then
          l_TG12 := conflict_TG_rec.terr_group_name;
          l_PARENT12 := conflict_TG_rec.parent_territory;
          end if;

          if J=13 then
          l_TG13 := conflict_TG_rec.terr_group_name;
          l_PARENT13 := conflict_TG_rec.parent_territory;
          end if;

          if J=14 then
          l_TG14 := conflict_TG_rec.terr_group_name;
          l_PARENT14 := conflict_TG_rec.parent_territory;
          end if;

          if J=15 then
          l_TG15 := conflict_TG_rec.terr_group_name;
          l_PARENT15 := conflict_TG_rec.parent_territory;
          end if;

          if J=16 then
          l_TG16 := conflict_TG_rec.terr_group_name;
          l_PARENT16 := conflict_TG_rec.parent_territory;
          end if;

          if J=17 then
          l_TG17 := conflict_TG_rec.terr_group_name;
          l_PARENT17 := conflict_TG_rec.parent_territory;
          end if;

          if J=18 then
          l_TG18 := conflict_TG_rec.terr_group_name;
          l_PARENT18 := conflict_TG_rec.parent_territory;
          end if;

          if J=19 then
          l_TG19 := conflict_TG_rec.terr_group_name;
          l_PARENT19 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          l_TG20 := conflict_TG_rec.terr_group_name;
          l_PARENT20 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          EXIT;
          end if;

        END LOOP;

        --insert record into table, if there the named accountbelongs to more than one territory group
        if J>1 then

        insert into JTF_TTY_WEBADI_INTERFACES
        ( user_sequence
         ,user_id
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,attribute16
         ,attribute17
         ,attribute18
         ,attribute19
         ,attribute20
         ,attribute21
         ,attribute22
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
         ,ATTRIBUTE31
         ,ATTRIBUTE32
         ,ATTRIBUTE33
         ,ATTRIBUTE34
         ,ATTRIBUTE35
         ,ATTRIBUTE36
         ,ATTRIBUTE37
         ,ATTRIBUTE38
         ,ATTRIBUTE39
         ,ATTRIBUTE40
         ,ATTRIBUTE41
         ,ATTRIBUTE42
         ,ATTRIBUTE43
         ,ATTRIBUTE44
         ,ATTRIBUTE45
         ,ATTRIBUTE46
         ,ATTRIBUTE47
         ,ATTRIBUTE48
         ,ATTRIBUTE49
         ,ATTRIBUTE50
         ,ATTRIBUTE51
         ,ATTRIBUTE52
         ,ATTRIBUTE53
         ,ATTRIBUTE54
         ,ATTRIBUTE55

        ) select
           l_seq
         , p_userid
         , HZP.party_name
         , LKP.meaning site_type
         , HZP.party_number
         , HZP.duns_number_c site_duns
         , HZP.known_as trade_name
         , null
         , null
         , null
         , null
         , HZP.city
         , HZP.state
         , HZP.postal_code
         , l_TG1
         , l_PARENT1
         , l_TG2
         , l_PARENT2
         , l_TG3
         , l_PARENT3
         , l_TG4
         , l_PARENT4
         , l_TG5
         , l_PARENT5
         , G_USER
         , SYSDATE
         , G_USER
         , SYSDATE
         , NA.PARTY_SITE_ID
         , l_TG6
         , l_PARENT6
         , l_TG7
         , l_PARENT7
         , l_TG8
         , l_PARENT8
         , l_TG9
         , l_PARENT9
         , l_TG10
         , l_PARENT10
         , l_TG11
         , l_PARENT11
         , l_TG12
         , l_PARENT12
         , l_TG13
         , l_PARENT13
         , l_TG14
         , l_PARENT14
         , l_TG15
         , l_PARENT15
         , l_TG16
         , l_PARENT16
         , l_TG17
         , l_PARENT17
         , l_TG18
         , l_PARENT18
         , l_TG19
         , l_PARENT19
         , l_TG20
         , l_PARENT20
          from
               jtf_tty_named_Accts NA
              ,hz_parties HZP
              ,fnd_lookups LKP
         where NA.named_account_id = p_named_account_id
          and NA.party_id = HZP.party_id
          and NA.site_type_code = LKP.lookup_code
          and LKP.lookup_type = 'JTF_TTY_SITE_TYPE_CODE';

        end if;

    elsif p_DUNS is not null
    then
      --find NAID's from DUNS
      FOR DUNS_NA_rec in c_NA_for_DUNS
      LOOP

      J := 0;
        --populate local variables to show conflicting TG denormalised for each NA
        FOR conflict_TG_rec in c_conflicting_TG(DUNS_NA_rec.named_account_id)
        LOOP
          J := J+1;
          --maximum of 5 conflicting TG's allowed in this report
          if J=1 then
          l_TG1 := conflict_TG_rec.terr_group_name;
          l_PARENT1 := conflict_TG_rec.parent_territory;
          end if;

          if J=2 then
          l_TG2 := conflict_TG_rec.terr_group_name;
          l_PARENT2 := conflict_TG_rec.parent_territory;
          end if;

          if J=3 then
          l_TG3 := conflict_TG_rec.terr_group_name;
          l_PARENT3 := conflict_TG_rec.parent_territory;
          end if;

          if J=4 then
          l_TG4 := conflict_TG_rec.terr_group_name;
          l_PARENT4 := conflict_TG_rec.parent_territory;
          end if;

          if J=5 then
          l_TG5 := conflict_TG_rec.terr_group_name;
          l_PARENT5 := conflict_TG_rec.parent_territory;
          end if;

          if J=6 then
          l_TG6 := conflict_TG_rec.terr_group_name;
          l_PARENT6 := conflict_TG_rec.parent_territory;
          end if;

          if J=7 then
          l_TG7 := conflict_TG_rec.terr_group_name;
          l_PARENT7 := conflict_TG_rec.parent_territory;
          end if;

          if J=8 then
          l_TG8 := conflict_TG_rec.terr_group_name;
          l_PARENT8 := conflict_TG_rec.parent_territory;
          end if;

          if J=9 then
          l_TG9 := conflict_TG_rec.terr_group_name;
          l_PARENT9 := conflict_TG_rec.parent_territory;
          end if;

          if J=10 then
          l_TG10 := conflict_TG_rec.terr_group_name;
          l_PARENT10 := conflict_TG_rec.parent_territory;
          end if;

          if J=11 then
          l_TG11 := conflict_TG_rec.terr_group_name;
          l_PARENT11 := conflict_TG_rec.parent_territory;
          end if;

          if J=12 then
          l_TG12 := conflict_TG_rec.terr_group_name;
          l_PARENT12 := conflict_TG_rec.parent_territory;
          end if;

          if J=13 then
          l_TG13 := conflict_TG_rec.terr_group_name;
          l_PARENT13 := conflict_TG_rec.parent_territory;
          end if;

          if J=14 then
          l_TG14 := conflict_TG_rec.terr_group_name;
          l_PARENT14 := conflict_TG_rec.parent_territory;
          end if;

          if J=15 then
          l_TG15 := conflict_TG_rec.terr_group_name;
          l_PARENT15 := conflict_TG_rec.parent_territory;
          end if;

          if J=16 then
          l_TG16 := conflict_TG_rec.terr_group_name;
          l_PARENT16 := conflict_TG_rec.parent_territory;
          end if;

          if J=17 then
          l_TG17 := conflict_TG_rec.terr_group_name;
          l_PARENT17 := conflict_TG_rec.parent_territory;
          end if;

          if J=18 then
          l_TG18 := conflict_TG_rec.terr_group_name;
          l_PARENT18 := conflict_TG_rec.parent_territory;
          end if;

          if J=19 then
          l_TG19 := conflict_TG_rec.terr_group_name;
          l_PARENT19 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          l_TG20 := conflict_TG_rec.terr_group_name;
          l_PARENT20 := conflict_TG_rec.parent_territory;
          end if;

          if J=20 then
          EXIT;
          end if;

        END LOOP;

        --insert record into table, if there the named accountbelongs to more than one territory group
        if J>1 then

        insert into JTF_TTY_WEBADI_INTERFACES
        ( user_sequence
         ,user_id
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,attribute16
         ,attribute17
         ,attribute18
         ,attribute19
         ,attribute20
         ,attribute21
         ,attribute22
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
        ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
         ,ATTRIBUTE31
         ,ATTRIBUTE32
         ,ATTRIBUTE33
         ,ATTRIBUTE34
         ,ATTRIBUTE35
         ,ATTRIBUTE36
         ,ATTRIBUTE37
         ,ATTRIBUTE38
         ,ATTRIBUTE39
         ,ATTRIBUTE40
         ,ATTRIBUTE41
         ,ATTRIBUTE42
         ,ATTRIBUTE43
         ,ATTRIBUTE44
         ,ATTRIBUTE45
         ,ATTRIBUTE46
         ,ATTRIBUTE47
         ,ATTRIBUTE48
         ,ATTRIBUTE49
         ,ATTRIBUTE50
         ,ATTRIBUTE51
         ,ATTRIBUTE52
         ,ATTRIBUTE53
         ,ATTRIBUTE54
         ,ATTRIBUTE55

        ) select
           l_seq
         , p_userid
         , HZP.party_name
         , LKP.meaning site_type
         , HZP.party_number
         , HZP.duns_number_c site_duns
         , HZP.known_as trade_name
         , null
         , null
         , null
         , null
         , HZP.city
         , HZP.state
         , HZP.postal_code
         , l_TG1
         , l_PARENT1
         , l_TG2
         , l_PARENT2
         , l_TG3
         , l_PARENT3
         , l_TG4
         , l_PARENT4
         , l_TG5
         , l_PARENT5
         , G_USER
         , SYSDATE
         , G_USER
         , SYSDATE
         ,NA.PARTY_SITE_ID
         , l_TG6
         , l_PARENT6
         , l_TG7
         , l_PARENT7
         , l_TG8
         , l_PARENT8
         , l_TG9
         , l_PARENT9
         , l_TG10
         , l_PARENT10
         , l_TG11
         , l_PARENT11
         , l_TG12
         , l_PARENT12
         , l_TG13
         , l_PARENT13
         , l_TG14
         , l_PARENT14
         , l_TG15
         , l_PARENT15
         , l_TG16
         , l_PARENT16
         , l_TG17
         , l_PARENT17
         , l_TG18
         , l_PARENT18
         , l_TG19
         , l_PARENT19
         , l_TG20
         , l_PARENT20

          from
               jtf_tty_named_Accts NA
              ,hz_parties HZP
              ,fnd_lookups LKP
         where NA.named_account_id = DUNS_NA_rec.named_account_id
          and NA.party_id = HZP.party_id
          and NA.site_type_code = LKP.lookup_code
          and LKP.lookup_type = 'JTF_TTY_SITE_TYPE_CODE';

        end if;
      l_TG1 :=null;
      l_TG2 :=null;
      l_TG3 :=null;
      l_TG4 :=null;
      l_TG5 :=null;
      l_TG6 :=null;
      l_TG7 :=null;
      l_TG8 :=null;
      l_TG9 :=null;
      l_TG10 :=null;
      l_TG11 :=null;
      l_TG12 :=null;
      l_TG13 :=null;
      l_TG14 :=null;
      l_TG15 :=null;
      l_TG16 :=null;
      l_TG17 :=null;
      l_TG18 :=null;
      l_TG19 :=null;
      l_TG20 :=null;

      l_PARENT1 :=null;
      l_PARENT2 :=null;
      l_PARENT3 :=null;
      l_PARENT4 :=null;
      l_PARENT5 :=null;
      l_PARENT6 :=null;
      l_PARENT7 :=null;
      l_PARENT8 :=null;
      l_PARENT9 :=null;
      l_PARENT10 :=null;
      l_PARENT11 :=null;
      l_PARENT12 :=null;
      l_PARENT13 :=null;
      l_PARENT14 :=null;
      l_PARENT15 :=null;
      l_PARENT16 :=null;
      l_PARENT17 :=null;
      l_PARENT18 :=null;
      l_PARENT19 :=null;
      l_PARENT20 :=null;


      END LOOP; --c_NA_for_DUNS

    end if; --territory group chosen

    COMMIT;

 END;

END JTF_TTY_OVERLAP_WEBADI_PKG;

/
