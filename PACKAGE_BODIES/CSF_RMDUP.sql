--------------------------------------------------------
--  DDL for Package Body CSF_RMDUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_RMDUP" as
/*$Header: csfrmdpb.pls 120.0 2005/05/25 11:11:44 appldev noship $*/

procedure clean_adm_bounds
is
  cursor c1( start_id NUMBER ) is
    select ADMIN_BOUND_ID, rowid
    from CSF_MD_ADM_BOUNDS
    where ADMIN_BOUND_ID >= start_id
    order by ADMIN_BOUND_ID;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.ADMIN_BOUND_ID ) then
        delete from CSF_MD_ADM_BOUNDS where rowid = r1.rowid;
      else
        min_start_id := r1.ADMIN_BOUND_ID;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_hydros
is
  cursor c1( start_id NUMBER ) is
    select hydrography_id, rowid
    from csf_md_hydros
    where hydrography_id >= start_id
    order by hydrography_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.hydrography_id ) then
        delete from csf_md_hydros where rowid = r1.rowid;
      else
        min_start_id := r1.hydrography_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_inst_style_shts
is
  cursor c1( start_id NUMBER ) is
    select INST_STYLE_ID, rowid
    from CSF_MD_INST_STYLE_SHTS
    where INST_STYLE_ID >= start_id
    order by INST_STYLE_ID;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.INST_STYLE_ID ) then
        delete from CSF_MD_INST_STYLE_SHTS where rowid = r1.rowid;
      else
        min_start_id := r1.INST_STYLE_ID;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_land_uses
is
  cursor c1( start_id NUMBER ) is
    select LANDUSE_ID, rowid
    from CSF_MD_LAND_USES
    where LANDUSE_ID >= start_id
    order by LANDUSE_ID;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.LANDUSE_ID ) then
        delete from CSF_MD_LAND_USES where rowid = r1.rowid;
      else
        min_start_id := r1.LANDUSE_ID;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_layer_metadata
is
  cursor c1( start_id NUMBER ) is
    select LAYER_METADATA_ID, rowid
    from CSF_MD_LYR_METADATA
    where LAYER_METADATA_ID >= start_id
    order by LAYER_METADATA_ID;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.LAYER_METADATA_ID ) then
        delete from CSF_MD_LYR_METADATA where rowid = r1.rowid;
      else
        min_start_id := r1.LAYER_METADATA_ID;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_layer_style_shts
is
  cursor c1( start_id NUMBER ) is
    select LAYER_STYLE_SHEET_ID, rowid
    from CSF_MD_LYR_STYLE_SHTS
    where LAYER_STYLE_SHEET_ID >= start_id
    order by LAYER_STYLE_SHEET_ID;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;
begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.LAYER_STYLE_SHEET_ID ) then
        delete from CSF_MD_LYR_STYLE_SHTS where rowid = r1.rowid;
      else
        min_start_id := r1.LAYER_STYLE_SHEET_ID;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_names
is
  cursor c1( start_id NUMBER ) is
    select name_id, rowid
    from csf_md_names
    where name_id >= start_id
    order by name_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.name_id ) then
        delete from csf_md_names where rowid = r1.rowid;
      else
        min_start_id := r1.name_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;
  end loop;
end;

procedure clean_pois
is
  cursor c1( start_id NUMBER ) is
    select poi_id, rowid
    from csf_md_pois
    where poi_id >= start_id
    order by poi_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.poi_id ) then
        delete from csf_md_pois where rowid = r1.rowid;
      else
        min_start_id := r1.poi_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_poi_names
is
  cursor c1( start_id NUMBER ) is
    select poi_nm_asgn_id, rowid
    from csf_md_poi_nm_asgns
    where poi_nm_asgn_id >= start_id
    order by poi_nm_asgn_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.poi_nm_asgn_id ) then
        delete from csf_md_poi_nm_asgns where rowid = r1.rowid;
      else
        min_start_id := r1.poi_nm_asgn_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_rail_segs
is
  cursor c1( start_id NUMBER ) is
    select railroad_segment_id, rowid
    from csf_md_rail_segs
    where railroad_segment_id >= start_id
    order by railroad_segment_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.railroad_segment_id ) then
        delete from csf_md_rail_segs where rowid = r1.rowid;
      else
        min_start_id := r1.railroad_segment_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_rdseg_names
is
  cursor c1( start_id NUMBER ) is
    select rd_seg_nm_id, rowid
    from csf_md_rdseg_nm_asgns
    where rd_seg_nm_id >= start_id
    order by rd_seg_nm_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.rd_seg_nm_id ) then
        delete from csf_md_rdseg_nm_asgns where rowid = r1.rowid;
      else
        min_start_id := r1.rd_seg_nm_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_road_segments
is
  cursor c1( start_id NUMBER ) is
    select road_segment_id, rowid
    from csf_md_rd_segs
    where road_segment_id >= start_id
    order by road_segment_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.road_segment_id ) then
        delete from csf_md_rd_segs where rowid = r1.rowid;
      else
        min_start_id := r1.road_segment_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

procedure clean_theme_metadata
is
  cursor c1( start_id NUMBER ) is
    select theme_id, rowid
    from csf_md_theme_metadata
    where theme_id >= start_id
    order by theme_id;
  r1 c1%ROWTYPE;

  einde BOOLEAN;
  min_start_id NUMBER;
  max_batch NUMBER := 1000;

begin
  min_start_id := -1;
  einde := false;

  loop
    open c1(min_start_id);
    loop
      fetch c1 into r1;

      if ( c1%NOTFOUND ) then
        einde := true;
        exit;
      end if;

      if ( min_start_id = r1.theme_id ) then
        delete from csf_md_theme_metadata where rowid = r1.rowid;
      else
        min_start_id := r1.theme_id;
      end if;

      exit when c1%ROWCOUNT > max_batch;

    end loop;
    close c1;

    commit;
    exit when einde;

  end loop;

end;

end csf_rmdup;

/
