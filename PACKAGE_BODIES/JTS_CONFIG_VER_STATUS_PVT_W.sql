--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VER_STATUS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VER_STATUS_PVT_W" as
  /* $Header: jtswcvsb.pls 115.2 2002/03/22 19:08:03 pkm ship    $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure any_version_replayed(p_api_version  NUMBER
    , p_config_id  NUMBER
    , x_replayed out  number
  )

  as
    ddx_replayed boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    jts_config_ver_status_pvt.any_version_replayed(p_api_version,
      p_config_id,
      ddx_replayed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_replayed is null
    then x_replayed := null;
  elsif ddx_replayed
    then x_replayed := 1;
  else x_replayed := 0;
  end if;
  end;

  procedure in_replay_status(p_api_version  NUMBER
    , p_status  VARCHAR2
    , ddrosetta_retval_bool OUT NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jts_config_ver_status_pvt.in_replay_status(p_api_version,
      p_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure in_version_status(p_api_version  NUMBER
    , p_status  VARCHAR2
    , ddrosetta_retval_bool OUT NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jts_config_ver_status_pvt.in_version_status(p_api_version,
      p_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure not_replayed(p_api_version  NUMBER
    , p_status  VARCHAR2
    , x_in_notreplayed out  number
  )

  as
    ddx_in_notreplayed boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    jts_config_ver_status_pvt.not_replayed(p_api_version,
      p_status,
      ddx_in_notreplayed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  if ddx_in_notreplayed is null
    then x_in_notreplayed := null;
  elsif ddx_in_notreplayed
    then x_in_notreplayed := 1;
  else x_in_notreplayed := 0;
  end if;
  end;

end jts_config_ver_status_pvt_w;

/
