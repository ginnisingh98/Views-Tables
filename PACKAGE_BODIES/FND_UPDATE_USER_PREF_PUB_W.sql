--------------------------------------------------------
--  DDL for Package Body FND_UPDATE_USER_PREF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_UPDATE_USER_PREF_PUB_W" as
  /* $Header: fndpirrb.pls 120.1 2005/07/02 03:35:17 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy fnd_update_user_pref_pub.preference_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).purpose_code := a0(indx);
          t(ddindx).purpose_default_code := a1(indx);
          t(ddindx).user_option := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t fnd_update_user_pref_pub.preference_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).purpose_code;
          a1(indx) := t(ddindx).purpose_default_code;
          a2(indx) := t(ddindx).user_option;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure set_purpose_option(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_user_id  NUMBER
    , p_party_id  NUMBER
    , p5_a0 JTF_VARCHAR2_TABLE_100
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_option fnd_update_user_pref_pub.preference_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    fnd_update_user_pref_pub_w.rosetta_table_copy_in_p1(ddp_option, p5_a0
      , p5_a1
      , p5_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    fnd_update_user_pref_pub.set_purpose_option(p_api_version,
      p_init_msg_list,
      p_commit,
      p_user_id,
      p_party_id,
      ddp_option,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end fnd_update_user_pref_pub_w;

/
