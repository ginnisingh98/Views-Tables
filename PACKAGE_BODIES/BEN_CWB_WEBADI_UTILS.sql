--------------------------------------------------------
--  DDL for Package Body BEN_CWB_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_WEBADI_UTILS" as
/* $Header: bencwbadiutl.pkb 120.10.12010000.10 2010/05/18 08:57:37 sgnanama ship $ */

--key_string VARCHAR2(32) := 'A!190j2#Az19?j1@A!190j2#Az19?j1@';
---added for custom download
g_interface_code VARCHAR2(40);

l_layout_lock_time VARCHAR2(5) := FND_PROFILE.VALUE('BEN_CWB_LAYOUT_LOCK_TIME');
key_string VARCHAR2(16) := substr(FND_PROFILE.VALUE('BEN_CWB_ENCRYPT_KEY'),1,16);

g_package  Varchar2(30) := 'BEN_CWB_WEBADI_UTILS.';
g_debug boolean := hr_utility.debug_enabled;

--
--------------------------create_cwb_layout_row----------------------
--

PROCEDURE create_cwb_layout_row(
      p_layout_code      IN   VARCHAR2
     ,p_user_name        IN   VARCHAR2
     ,p_base_layout_code IN VARCHAR2)
IS

l_rowid VARCHAR2(200);
no_default_layout EXCEPTION;
l_proc   varchar2(72) := g_package||'create_cwb_layout_row';


CURSOR c_layout_row
IS
SELECT application_id
       ,object_version_number
       ,stylesheet_app_id
       ,stylesheet_code
       ,integrator_app_id
       ,integrator_code
       ,style
       ,style_class
       ,reporting_flag
       ,reporting_interface_app_id
       ,reporting_interface_code
       ,created_by
       ,last_updated_by
       ,last_update_login
FROM  bne_layouts_b
WHERE application_id = 800
AND   layout_code = p_base_layout_code;

l_layout_row c_layout_row%ROWTYPE;


BEGIN

OPEN c_layout_row;
FETCH c_layout_row  INTO l_layout_row;
IF c_layout_row%NOTFOUND THEN
         RAISE no_default_layout;
END IF;
CLOSE c_layout_row;

bne_layouts_pkg.insert_row
         (x_rowid                           => l_rowid
         ,x_application_id                  => l_layout_row.application_id
         ,x_layout_code                     => p_layout_code
         ,x_object_version_number           => 1
         ,x_stylesheet_app_id               => l_layout_row.stylesheet_app_id
         ,x_stylesheet_code                 => l_layout_row.stylesheet_code
         ,x_integrator_app_id               => l_layout_row.integrator_app_id
         ,x_integrator_code                 => l_layout_row.integrator_code
         ,x_style                           => l_layout_row.style
         ,x_style_class                     => l_layout_row.style_class
         ,x_reporting_flag                  => l_layout_row.reporting_flag
         ,x_reporting_interface_app_id      => l_layout_row.reporting_interface_app_id
         ,x_reporting_interface_code        => l_layout_row.reporting_interface_code
         ,x_user_name                       => p_user_name
         ,x_creation_date                   => SYSDATE
         ,x_created_by                      => l_layout_row.created_by
         ,x_last_update_date                => SYSDATE
         ,x_last_updated_by                 => l_layout_row.last_updated_by
         ,x_last_update_login               => l_layout_row.last_update_login);
END create_cwb_layout_row;

--
--------------------------create_cwb_layout_blocks_row----------------------
--

PROCEDURE create_cwb_layout_blocks_row(
      p_layout_code      IN   VARCHAR2
     ,p_user_name        IN   VARCHAR2
     ,p_base_layout_code IN   VARCHAR2)
IS

l_rowid VARCHAR2(200);
CURSOR c_layout_blocks_row  IS
SELECT   application_id
         ,block_id
         ,parent_id
         ,layout_element
         ,style_class
         ,style
         ,row_style_class
         ,row_style
         ,col_style_class
         ,col_style
         ,prompt_displayed_flag
         ,prompt_style_class
         ,prompt_style
         ,hint_displayed_flag
         ,hint_style_class
         ,hint_style
         ,orientation
         ,layout_control
         ,display_flag
         ,BLOCKSIZE
         ,minsize
         ,MAXSIZE
         ,sequence_num
         ,prompt_colspan
         ,hint_colspan
         ,row_colspan
         ,summary_style_class
         ,summary_style
         ,created_by
         ,last_updated_by
         ,last_update_login
FROM  bne_layout_blocks_b
WHERE application_id = 800
AND   layout_code = p_base_layout_code
ORDER BY block_id;

l_layout_blocks_row c_layout_blocks_row%ROWTYPE;
BEGIN

OPEN c_layout_blocks_row;
LOOP
     FETCH c_layout_blocks_row  INTO l_layout_blocks_row;
     EXIT WHEN c_layout_blocks_row%NOTFOUND;
     bne_layout_blocks_pkg.insert_row
            (x_rowid                      => l_rowid
            ,x_application_id             => l_layout_blocks_row.application_id
            ,x_layout_code                => p_layout_code
            ,x_block_id                   => l_layout_blocks_row.block_id
            ,x_object_version_number      => 1
            ,x_parent_id                  => l_layout_blocks_row.parent_id
            ,x_layout_element             => l_layout_blocks_row.layout_element
            ,x_style_class                => l_layout_blocks_row.style_class
            ,x_style                      => l_layout_blocks_row.style
            ,x_row_style_class            => l_layout_blocks_row.row_style_class
            ,x_row_style                  => l_layout_blocks_row.row_style
            ,x_col_style_class            => l_layout_blocks_row.col_style_class
            ,x_col_style                  => l_layout_blocks_row.col_style
            ,x_prompt_displayed_flag      => l_layout_blocks_row.prompt_displayed_flag
            ,x_prompt_style_class         => l_layout_blocks_row.prompt_style_class
            ,x_prompt_style               => l_layout_blocks_row.prompt_style
            ,x_hint_displayed_flag        => l_layout_blocks_row.hint_displayed_flag
            ,x_hint_style_class           => l_layout_blocks_row.hint_style_class
            ,x_hint_style                 => l_layout_blocks_row.hint_style
            ,x_orientation                => l_layout_blocks_row.orientation
            ,x_layout_control             => l_layout_blocks_row.layout_control
            ,x_display_flag               => l_layout_blocks_row.display_flag
            ,x_blocksize                  => l_layout_blocks_row.BLOCKSIZE
            ,x_minsize                    => l_layout_blocks_row.minsize
            ,x_maxsize                    => l_layout_blocks_row.MAXSIZE
            ,x_sequence_num               => l_layout_blocks_row.sequence_num
            ,x_prompt_colspan             => l_layout_blocks_row.prompt_colspan
            ,x_hint_colspan               => l_layout_blocks_row.hint_colspan
            ,x_row_colspan                => l_layout_blocks_row.row_colspan
            ,x_summary_style_class        => l_layout_blocks_row.summary_style_class
            ,x_summary_style              => l_layout_blocks_row.summary_style
            ,x_user_name                  => p_user_name
            ,x_creation_date              => SYSDATE
            ,x_created_by                 => l_layout_blocks_row.created_by
            ,x_last_update_date           => SYSDATE
            ,x_last_updated_by            => l_layout_blocks_row.last_updated_by
            ,x_last_update_login          => l_layout_blocks_row.last_update_login);
END LOOP;

CLOSE c_layout_blocks_row;
END create_cwb_layout_blocks_row;

--
--------------------------create_cwb_layout_cols_row----------------------
--

PROCEDURE create_cwb_layout_cols_row(p_layout_code      IN   VARCHAR2
                                    ,p_base_layout_code IN   VARCHAR2)  IS
      l_rowid VARCHAR2(200);

CURSOR c_layout_cols_row IS
SELECT   application_id
                 ,layout_code
                 ,block_id
                 ,interface_app_id
                 ,interface_code
                 ,interface_seq_num
                 ,sequence_num
                 ,style
                 ,style_class
                 ,hint_style
                 ,hint_style_class
                 ,prompt_style
                 ,prompt_style_class
                 ,default_type
                 ,DEFAULT_VALUE
                 ,created_by
                 ,last_updated_by
                 ,last_update_login
		 ,read_only_flag
FROM  bne_layout_cols
WHERE application_id = 800
AND   layout_code = p_base_layout_code
ORDER BY block_id;

l_layout_cols_row c_layout_cols_row%ROWTYPE;

l_read_only_flag VARCHAR2(1) := NULL;
l_display_width  NUMBER      := NULL;

BEGIN
      OPEN c_layout_cols_row;
      LOOP
         FETCH c_layout_cols_row INTO l_layout_cols_row;

         EXIT WHEN c_layout_cols_row%NOTFOUND;

         IF ((substr(p_base_layout_code,1,16) = 'BEN_CWB_WS_LYT1_')
            OR (p_base_layout_code = 'BEN_CWB_WRK_SHT_BASE_LYT')) THEN
         l_read_only_flag := 'Y';
          --Hide the contextual security keys
          IF (l_layout_cols_row.interface_seq_num IN (158, 189, 194, 195, 196, 198)) then
              l_display_width  := 0;
          --Hide the security keys in lines
          ELSIF (l_layout_cols_row.interface_seq_num IN (130, 131, 132, 133, 134)) then
              l_display_width  := 0;
              l_read_only_flag := 'N';
          --Make non-updateable columns as read-only
          ELSIF (l_layout_cols_row.interface_seq_num IN (3,12,30,48,66,84,151,152,192,191,126) OR
                 l_layout_cols_row.interface_seq_num BETWEEN 200 AND 234 OR
          -- ER : ability to update other rates and custom segments
                 l_layout_cols_row.interface_seq_num BETWEEN 136 AND 150 OR
                 l_layout_cols_row.interface_seq_num in (165,8,26,44,62,80,10,28,46,64,82,11,29,47,65,83,19,20,21,37,38,39,55,56,57,73,74,75,91,92,93)
     --changed by KMG included the below condition
              OR l_layout_cols_row.interface_seq_num BETWEEN 240 and 244) THEN
              l_read_only_flag := 'N';
          END IF;
	  IF(l_read_only_flag = 'N') THEN
		l_read_only_flag := l_layout_cols_row.read_only_flag;
	  END IF;
         END IF;


         bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row.application_id
                ,x_layout_code                => p_layout_code
                ,x_block_id                   => l_layout_cols_row.block_id
                ,x_sequence_num               => l_layout_cols_row.sequence_num
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row.interface_app_id
                ,x_interface_code             => l_layout_cols_row.interface_code
                ,x_interface_seq_num          => l_layout_cols_row.interface_seq_num
                ,x_style_class                => l_layout_cols_row.style_class
                ,x_hint_style                 => l_layout_cols_row.hint_style
                ,x_hint_style_class           => l_layout_cols_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row.prompt_style_class
                ,x_default_type               => l_layout_cols_row.default_type
                ,x_default_value              => l_layout_cols_row.DEFAULT_VALUE
                ,x_style                      => l_layout_cols_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_row.last_update_login
                ,x_read_only_flag             => l_read_only_flag
                ,x_display_width              => l_display_width);
      END LOOP;
      CLOSE c_layout_cols_row;

END create_cwb_layout_cols_row;

--
--------------------------create_cwb_layout----------------------
--

PROCEDURE create_cwb_layout(
      p_layout_code      IN   VARCHAR2
     ,p_user_name        IN   VARCHAR2
     ,p_base_layout_code IN VARCHAR2) IS
BEGIN
      create_cwb_layout_row(p_layout_code      => p_layout_code
                           ,p_user_name        => p_user_name
                           ,p_base_layout_code => p_base_layout_code);

      create_cwb_layout_blocks_row(p_layout_code      => p_layout_code
                                  ,p_user_name        => p_user_name
                                  ,p_base_layout_code => p_base_layout_code);

      create_cwb_layout_cols_row(p_layout_code => p_layout_code
              ,p_base_layout_code => p_base_layout_code);

END create_cwb_layout;

--
--------------------------delete_cwb_layout_cols----------------------
--

PROCEDURE delete_cwb_layout_cols(p_layout_code     IN   VARCHAR2
                                ,p_application_id  IN   NUMBER )
IS

l_proc  Varchar2(72):= 'delete_cwb_layout_cols';
CURSOR c_layout_cols
IS
SELECT  blc.application_id
       ,blc.layout_code
       ,blc.block_id
       ,blc.sequence_num
 FROM   bne_layout_cols blc
WHERE   blc.application_id = p_application_id
  AND   blc.layout_code    = p_layout_code;

BEGIN
      hr_utility.set_location('Entering '||l_proc,10);
      For l_layout_col_rec In c_layout_cols
      LOOP
            hr_utility.set_location('Seq Num :'||l_layout_col_rec.sequence_num,25);
            bne_layout_cols_pkg.delete_row
                         (x_application_id      => l_layout_col_rec.application_id
                         ,x_layout_code         => l_layout_col_rec.layout_code
                         ,x_block_id            => l_layout_col_rec.block_id
                         ,x_sequence_num        => l_layout_col_rec.sequence_num);
       END LOOP;
       hr_utility.set_location('Leaving '||l_proc,100);
EXCEPTION
    WHEN OTHERS   THEN
     hr_utility.set_location('ERROR occured',30);
     Null;
END delete_cwb_layout_cols;

--
----------------------------check_hidden_worksheet_columns ------------------------
--
procedure check_hidden_worksheet_columns(  p_group_pl_id           IN NUMBER
                                          ,p_lf_evt_ocrd_dt        IN DATE
                                          ,p_show_hide_data        OUT NOCOPY p_show_hide_data
                                          )
IS

l_show_hide_data  ben_cwb_webadi_utils.p_show_hide_data;

cursor group_opt_exists
IS
  select  count(group_oipl_id)    IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,null                    ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and group_pl_id = pl_id
    and group_oipl_id = oipl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
  and group_oipl_id <> -1;

cursor actual_opt_exists
IS
  select count(oipl_id)        IdCount
        ,max(ws_abr_id)        ws_abr_id
        ,max(elig_sal_abr_id)  elig_sal_abr_id
        ,max(ws_nnmntry_uom)   ws_nnmntry_uom
        ,null                  ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and group_pl_id = pl_id
    and group_oipl_id <> oipl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
  and group_oipl_id <> -1;

cursor  opt1_exists
IS
  select  count(group_oipl_id)    IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,null                    ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and group_oipl_id <> -1
    and oipl_ordr_num = 1;

cursor  opt2_exists
IS
  select  count(group_oipl_id)    IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,null                    ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and group_oipl_id <> -1
    and oipl_ordr_num = 2;

cursor  opt3_exists
IS
  select  count(group_oipl_id)    IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,null                    ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and group_oipl_id <> -1
    and oipl_ordr_num = 3;

cursor  opt4_exists
IS
  select  count(group_oipl_id)    IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,null                    ws_sub_acty_typ_cd
   from ben_cwb_pl_dsgn
  where group_pl_id = p_group_pl_id
    and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
    and group_oipl_id <> -1
    and oipl_ordr_num = 4;

cursor actual_plans
IS
  select count(pl_id)             IdCount
         ,max(ws_abr_id)          ws_abr_id
         ,max(elig_sal_abr_id)    elig_sal_abr_id
         ,max(ws_nnmntry_uom)     ws_nnmntry_uom
         ,max(ws_sub_acty_typ_cd) ws_sub_acty_typ_cd
    from ben_cwb_pl_dsgn
   where group_pl_id = p_group_pl_id
     and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
     and group_pl_id <> pl_id
     and group_oipl_id = -1
     and oipl_id = -1;

cursor group_plan
IS
  select count(group_pl_id)      IdCount
        ,max(ws_abr_id)          ws_abr_id
        ,max(elig_sal_abr_id)    elig_sal_abr_id
        ,max(ws_nnmntry_uom)     ws_nnmntry_uom
        ,max(ws_sub_acty_typ_cd) ws_sub_acty_typ_cd
    from ben_cwb_pl_dsgn
   where group_pl_id = p_group_pl_id
     and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
     and group_pl_id = pl_id
     and group_oipl_id = -1
     and oipl_id = -1;

l_group_opt_exists_rec      group_opt_exists%RowType;
l_actual_opt_exists_rec     actual_opt_exists%RowType;
l_group_plan_rec            group_plan%RowType;
l_actual_plans_rec          actual_plans%RowType;
l_opt1_exists_rec           opt1_exists%RowType;
l_opt2_exists_rec           opt2_exists%RowType;
l_opt3_exists_rec           opt3_exists%RowType;
l_opt4_exists_rec           opt4_exists%RowType;
l_count                     Number;


begin
    Open group_opt_exists;
    Fetch group_opt_exists into l_group_opt_exists_rec;
    Close group_opt_exists;

    Open actual_opt_exists;
    Fetch actual_opt_exists into l_actual_opt_exists_rec;
    Close actual_opt_exists;

    Open actual_plans;
    Fetch actual_plans into l_actual_plans_rec;
    Close actual_plans;

    Open group_plan;
    Fetch group_plan into l_group_plan_rec;
    Close group_plan;


    If (l_group_opt_exists_rec.IdCount <> 0  OR l_actual_opt_exists_rec.IdCount <> 0) Then

        -- If Group Options Exists
        Begin
              hr_utility.set_location('Options Exists',50);
              Open opt1_exists;
              Fetch opt1_exists into l_opt1_exists_rec;
              Close opt1_exists;

              Open opt2_exists;
              Fetch opt2_exists into l_opt2_exists_rec;
              Close opt2_exists;

              Open opt3_exists;
              Fetch opt3_exists into l_opt3_exists_rec;
              Close opt3_exists;

              Open opt4_exists;
              Fetch opt4_exists into l_opt4_exists_rec;
              Close opt4_exists;

----------------------------- Option 1 ------------------------------------------
              l_count := l_show_hide_data.count +1 ;
              If (l_opt1_exists_rec.IdCount <> 0) then
                  l_show_hide_data(l_count).p_type := 'OPT1';
                  l_show_hide_data(l_count).p_opt_defined := 'Y';

                  hr_utility.set_location('Opt1 Exists .. Count :'||l_count,100);
                  hr_utility.set_location('OPT1 ...'||l_show_hide_data(l_count).p_type,105);


                    If l_opt1_exists_rec.ws_abr_id is not Null Then
                            l_show_hide_data(l_count).p_ws_defined := 'Y';
                    Else
                         l_show_hide_data(l_count).p_ws_defined := 'N';
                    End if;

                    If  l_opt1_exists_rec.elig_sal_abr_id is not Null  Then
                         l_show_hide_data(l_count).p_eligy_sal_defined := 'Y';
                    Else
                        l_show_hide_data(l_count).p_eligy_sal_defined  := 'N';
                    End if;

                    If l_opt1_exists_rec.ws_nnmntry_uom is not Null Then
                        l_show_hide_data(l_count).p_nnmntry_uom := 'Y';
                    Else
                        l_show_hide_data(l_count).p_nnmntry_uom := 'N';
                   End if;
              hr_utility.set_location('OPT1 ...'||l_show_hide_data(l_count).p_type,105);
              hr_utility.set_location('OPT1 ...'||l_show_hide_data(l_count).p_ws_defined,115);
              hr_utility.set_location('OPT1 ...'||l_show_hide_data(l_count).p_eligy_sal_defined,120);
              hr_utility.set_location('OPT1 ...'||l_show_hide_data(l_count).p_nnmntry_uom,125);

              Else
                  l_show_hide_data(l_count).p_type := 'OPT1';
                  l_show_hide_data(l_count).p_opt_defined := 'N';
                  hr_utility.set_location('Opt1 Not Exists',120);
              End If;

----------------------------- Option 2 ------------------------------------------
              l_count := l_show_hide_data.count +1 ;
              If (l_opt2_exists_rec.IdCount <> 0) then
                    l_show_hide_data(l_count).p_type := 'OPT2';
                    l_show_hide_data(l_count).p_opt_defined := 'Y';

                    hr_utility.set_location('Opt2  Exists... Count :'||l_count,170);
                    hr_utility.set_location('OPT2 ...'||l_show_hide_data(l_count).p_type,175);

                    If l_opt2_exists_rec.ws_abr_id is not Null Then
                            l_show_hide_data(l_count).p_ws_defined := 'Y';
                    Else
                            l_show_hide_data(l_count).p_ws_defined := 'N';
                    End if;

                    If  l_opt2_exists_rec.elig_sal_abr_id is not Null  Then
                         l_show_hide_data(l_count).p_eligy_sal_defined := 'Y';
                    Else
                        l_show_hide_data(l_count).p_eligy_sal_defined := 'N';
                    End if;

                    If l_opt2_exists_rec.ws_nnmntry_uom is not Null Then
                        l_show_hide_data(l_count).p_nnmntry_uom := 'Y';
                    Else
                        l_show_hide_data(l_count).p_nnmntry_uom := 'N';
                   End if;
              hr_utility.set_location('OPT2 ...'||l_show_hide_data(l_count).p_type,250);
              hr_utility.set_location('OPT2 ...'||l_show_hide_data(l_count).p_ws_defined,255);
              hr_utility.set_location('OPT2 ...'||l_show_hide_data(l_count).p_eligy_sal_defined,260);
              hr_utility.set_location('OPT2 ...'||l_show_hide_data(l_count).p_nnmntry_uom,265);

              Else
                   hr_utility.set_location('Opt2 Not Exists',240);
                   l_show_hide_data(l_count).p_type := 'OPT2';
                   l_show_hide_data(l_count).p_opt_defined := 'N';
              End If;


----------------------------- Option 3 ------------------------------------------
              l_count := l_show_hide_data.count +1 ;
              If (l_opt3_exists_rec.IdCount <> 0) then

                    l_show_hide_data(l_count).p_type := 'OPT3';
                    l_show_hide_data(l_count).p_opt_defined := 'Y';

                    hr_utility.set_location('Opt3  Exists...Count :'||l_count,300);
                    hr_utility.set_location('OPT3 ...'||l_show_hide_data(l_count).p_type,305);
                    If l_opt3_exists_rec.ws_abr_id is not Null Then
                            l_show_hide_data(l_count).p_ws_defined := 'Y';
                    Else
                            l_show_hide_data(l_count).p_ws_defined := 'N';
                    End if;

                    If  l_opt3_exists_rec.elig_sal_abr_id is not Null  Then
                         l_show_hide_data(l_count).p_eligy_sal_defined := 'Y';
                    Else
                         l_show_hide_data(l_count).p_eligy_sal_defined:= 'N';
                    End if;

                    If l_opt3_exists_rec.ws_nnmntry_uom is not Null Then
                        l_show_hide_data(l_count).p_nnmntry_uom := 'Y';
                    Else
                        l_show_hide_data(l_count).p_nnmntry_uom := 'N';
                   End if;
              hr_utility.set_location('OPT3 ...'||l_show_hide_data(l_count).p_type,355);
              hr_utility.set_location('OPT3 ...'||l_show_hide_data(l_count).p_ws_defined,360);
              hr_utility.set_location('OPT3 ...'||l_show_hide_data(l_count).p_eligy_sal_defined,365);
              hr_utility.set_location('OPT3 ...'||l_show_hide_data(l_count).p_nnmntry_uom,370);

              Else
                  l_show_hide_data(l_count).p_type := 'OPT3';
                  l_show_hide_data(l_count).p_opt_defined := 'N';
                  hr_utility.set_location('Opt3  Not  Exists',350);
              End If;

   ----------------------------- Option 4 ------------------------------------------
              l_count := l_show_hide_data.count +1 ;
              If (l_opt4_exists_rec.IdCount <> 0) then

                    l_show_hide_data(l_count).p_type := 'OPT4';
                    l_show_hide_data(l_count).p_opt_defined := 'Y';

                    hr_utility.set_location('Opt4 Exists...Count :'||l_count,400);
                    hr_utility.set_location('OPT4 ...'||l_show_hide_data(l_count).p_type,405);
                    If l_opt4_exists_rec.ws_abr_id is not Null Then
                            l_show_hide_data(l_count).p_ws_defined := 'Y';
                    Else
                            l_show_hide_data(l_count).p_ws_defined := 'N';
                    End if;

                    If  l_opt4_exists_rec.elig_sal_abr_id is not Null  Then
                         l_show_hide_data(l_count).p_eligy_sal_defined := 'Y';
                    Else
                         l_show_hide_data(l_count).p_eligy_sal_defined := 'N';
                    End if;

                    If l_opt4_exists_rec.ws_nnmntry_uom is not Null Then
                        l_show_hide_data(l_count).p_nnmntry_uom := 'Y';
                    Else
                        l_show_hide_data(l_count).p_nnmntry_uom := 'N';
                   End if;
              hr_utility.set_location('OPT4 ...'||l_show_hide_data(l_count).p_type,555);
              hr_utility.set_location('OPT4 ...'||l_show_hide_data(l_count).p_ws_defined,560);
              hr_utility.set_location('OPT4 ...'||l_show_hide_data(l_count).p_eligy_sal_defined,565);
              hr_utility.set_location('OPT4 ...'||l_show_hide_data(l_count).p_nnmntry_uom,570);

              Else
                  l_show_hide_data(l_count).p_type := 'OPT4';
                  l_show_hide_data(l_count).p_opt_defined := 'N';
                  hr_utility.set_location('Opt4 Not Exists',500);
              End If;
       End;

    Else
     ----------------------------- Plan Only------------------------------------------

      Begin
         -- If Group Options not exists
         l_count := l_show_hide_data.count +1 ;
         l_show_hide_data(l_count).p_type := 'PLOY';
         l_show_hide_data(l_count).p_opt_defined := 'N';
         hr_utility.set_location('Options Not  Exists ...Count :'||l_count,560);
          If (l_actual_plans_rec.ws_abr_id is not Null OR
             l_group_plan_rec.ws_abr_id is not Null )Then
                l_show_hide_data(l_count).p_ws_defined := 'Y';
          Else
                l_show_hide_data(l_count).p_ws_defined := 'N';
          End if;

          If ( l_actual_plans_rec.elig_sal_abr_id is not Null OR
               l_group_plan_rec.elig_sal_abr_id is not Null) Then
                l_show_hide_data(l_count).p_eligy_sal_defined := 'Y';
          Else
                l_show_hide_data(l_count).p_eligy_sal_defined := 'N';
          End if;

          If (l_actual_plans_rec.ws_nnmntry_uom is not Null OR
              l_group_plan_rec.ws_nnmntry_uom is not Null)  Then
                l_show_hide_data(l_count).p_nnmntry_uom := 'Y';
          Else
                l_show_hide_data(l_count).p_nnmntry_uom := 'N';
          End if;

          If (l_actual_plans_rec.ws_sub_acty_typ_cd = 'ICM7'   OR
                l_group_plan_rec.ws_sub_acty_typ_cd = 'ICM7')  Then
                l_show_hide_data(l_count).p_ws_sub_acty_typ_cd := 'Y';
          Else
                l_show_hide_data(l_count).p_ws_sub_acty_typ_cd := 'N';
          End if;


    End;
    End If;
    hr_utility.set_location('Final count'||l_count, 500);

    For i in l_show_hide_data.first..l_show_hide_data.last
    Loop
      hr_utility.set_location('p_type('||i||') :'||l_show_hide_data(i).p_type, 500);
       hr_utility.set_location('p_opt_defined('||i||') :'||l_show_hide_data(i).p_opt_defined, 510);
       hr_utility.set_location('p_ws_defined('||i||') :'||l_show_hide_data(i).p_ws_defined, 520);
       hr_utility.set_location('p_eligy_sal_defined('||i||') :'||l_show_hide_data(i).p_eligy_sal_defined, 530);
       hr_utility.set_location('p_nnmntry_uom('||i||') :'||l_show_hide_data(i).p_nnmntry_uom, 540);
       hr_utility.set_location('ws_sub_acty_typ_cd('||i||') :'||l_show_hide_data(i).p_ws_sub_acty_typ_cd, 541);

    End Loop;
    p_show_hide_data := l_show_hide_data;
    Exception
     when others then
        hr_utility.set_location('sqlerrm:'||substr(sqlerrm,1,50), 100);
        hr_utility.set_location('sqlerrm:'||substr(sqlerrm,51,100), 101);
        hr_utility.set_location('sqlerrm:'||substr(sqlerrm,101,150), 102);

end check_hidden_worksheet_columns;
--
------------------------ decide_insert_rec-----------------------
--
Function decide_insert_rec (p_inf_seq          IN NUMBER
                           ,p_group_pl_id      IN NUMBER
                           ,p_lf_evt_ocrd_dt   IN DATE )
Return Varchar IS

Cursor  csr_is_options IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15)='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  And   INTERFACE_COL_NAME like '%OPT%'
  AND   interface_code = g_interface_code
  And   application_id = 800
  And   SEQUENCE_NUM = p_inf_seq;

Cursor  csr_opt1 IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15) ='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  And   INTERFACE_COL_NAME like '%OPT1%'
  AND   interface_code = g_interface_code
  And   application_id = 800
  And   SEQUENCE_NUM     = p_inf_seq;

Cursor  csr_opt2 IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15) ='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  AND   interface_code = g_interface_code
  And   INTERFACE_COL_NAME like '%OPT2%'
  And   application_id = 800
  And   SEQUENCE_NUM     = p_inf_seq;

Cursor  csr_opt3 IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15) ='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  AND   interface_code = g_interface_code
  And   INTERFACE_COL_NAME like '%OPT3%'
  And   application_id = 800
  And   SEQUENCE_NUM     = p_inf_seq;

Cursor  csr_opt4 IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15) ='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  AND   interface_code = g_interface_code
  And   INTERFACE_COL_NAME like '%OPT4%'
  And   application_id = 800
  And   SEQUENCE_NUM     = p_inf_seq;

cursor csr_asg_updt_date is
select '1'
from ben_cwb_pl_dsgn
where pl_id = p_group_pl_id
and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
and asg_updt_eff_date is not null;

Cursor  csr_promotions IS
Select  '1'
  From  bne_interface_cols_b
 where  (substr(interface_code,1,15) ='BEN_CWB_WS_INTF'
 OR interface_code = 'BEN_CWB_WRK_SHT_INTF')
  AND   interface_code = g_interface_code
  And   SEQUENCE_NUM in (126,152,191,192)
  And   application_id = 800
  And   SEQUENCE_NUM     = p_inf_seq;


l_insert_rec         Varchar(1):= 'Y';
l_option             VARCHAR2(1);
l_show_hide_data  ben_cwb_webadi_utils.p_show_hide_data;
l_PLOY_index         Number := 0;
l_OPT1_index         Number := 0;
l_OPT2_index         Number := 0;
l_OPT3_index         Number := 0;
l_OPT4_index         Number := 0;
l_proc       Varchar2(72) := g_package||'decide_insert_rec';


Begin

hr_utility.set_location('Entering :'||l_proc,10);
hr_utility.set_location('** p_inf_seq :'||p_inf_seq,20);

check_hidden_worksheet_columns(  p_group_pl_id        => p_group_pl_id
                                ,p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt
                                ,p_show_hide_data     => l_show_hide_data);



 hr_utility.set_location('l_show_hide_data.count :'||l_show_hide_data.count,785);
 hr_utility.set_location('l_show_hide_data.first :'||l_show_hide_data.first,786);
 hr_utility.set_location('l_show_hide_data.last :'||l_show_hide_data.last,787);


 /*open csr_promotions;
 fetch csr_promotions  into l_option;
 close csr_promotions;
 If l_option is not null then
    open csr_asg_updt_date;
    fetch csr_asg_updt_date  into l_option;
    close csr_asg_updt_date;
    if l_option is null then
        l_insert_rec := 'N';
        hr_utility.set_location('Assignment Update Effective Date Not defined for the plan :' || p_group_pl_id,785);
    end if;
 End if;*/


For i in l_show_hide_data.first..l_show_hide_data.last
Loop
       hr_utility.set_location('p_type('||i||') :'||l_show_hide_data(i).p_type, 4900);
       hr_utility.set_location('p_opt_defined('||i||') :'||l_show_hide_data(i).p_opt_defined, 500);
       hr_utility.set_location('p_ws_defined('||i||') :'||l_show_hide_data(i).p_ws_defined, 510);
       hr_utility.set_location('p_eligy_sal_defined('||i||') :'||l_show_hide_data(i).p_eligy_sal_defined, 520);
       hr_utility.set_location('p_nnmntry_uom('||i||') :'||l_show_hide_data(i).p_nnmntry_uom, 530);

       if (l_show_hide_data(i).p_type = 'PLOY') then
             l_PLOY_index := i;
       end if;

       if (l_show_hide_data(i).p_type = 'OPT1') then
             l_OPT1_index := i;
       end if;

       if (l_show_hide_data(i).p_type = 'OPT2') then
             l_OPT2_index := i;
       end if;

       if (l_show_hide_data(i).p_type = 'OPT3') then
             l_OPT3_index := i;
       end if;

       if (l_show_hide_data(i).p_type = 'OPT4') then
             l_OPT4_index := i;
       end if;
End Loop;
 hr_utility.set_location('l_PLOY_index :'||l_PLOY_index,540);
 hr_utility.set_location('l_OPT1_index :'||l_OPT1_index,541);
 hr_utility.set_location('l_OPT2_index :'||l_OPT2_index,542);
 hr_utility.set_location('l_OPT3_index :'||l_OPT3_index,543);
 hr_utility.set_location('l_OPT4_index :'||l_OPT4_index,544);


--------------------------------Start of Plan Only--------------------------------
  IF (l_PLOY_index <> 0 and l_show_hide_data(l_PLOY_index).p_type = 'PLOY'  ) THEN
  Begin
           hr_utility.set_location('Start of Plan Only',545);
          -- If No Options Exists then disable all Option Columns
           Open csr_is_options;
           Fetch csr_is_options into l_option;
           Close csr_is_options;
           If l_option is not null then
                l_insert_rec := 'N';
           End if;

           -- Plan Level Checks
           If  l_show_hide_data(l_PLOY_index).p_ws_defined = 'N' And (p_inf_seq  in (12,7,159,165,9,5,164) ) then
               hr_utility.set_location('Plan WS Aount Not defined....',800);
               hr_utility.set_location('p_inf_seq : (12,7,159,165,9,5,164)'||p_inf_seq,820);
              l_insert_rec := 'N';
           End if;

           If  l_show_hide_data(l_PLOY_index).p_eligy_sal_defined = 'N' And (p_inf_seq  in (165,9,5,164) ) then
               hr_utility.set_location( 'Plan Eligible Sal Not Defined...',820);
               hr_utility.set_location('p_inf_seq : (165,9,5,164)'||p_inf_seq,850);
               l_insert_rec := 'N';
           End if;

       /*    If l_show_hide_data(l_PLOY_index).p_nnmntry_uom = 'Y' And( p_inf_seq  in (7,159,165,9,5,164)) then
                hr_utility.set_location( 'Plan is Non monetory Unit...',860);
                hr_utility.set_location('p_inf_seq : (7,159,165,9,5,164)'||p_inf_seq,850);
               l_insert_rec := 'N';
          End if;
          */
          ----------------------------------
          -- If Plan is Non-Monetory unit and Eligible Salary is defined then
          -- enable Eligible Salary and
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Base Salary, New Salary

          -- If Plan is Non-Monetory unit and Eligible Salary is not defined then
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Eligible Salary  Base Salary, New Salary
           If l_show_hide_data(l_PLOY_index).p_nnmntry_uom = 'Y' Then

              If l_show_hide_data(l_PLOY_index).p_eligy_sal_defined = 'Y' Then
                   -- mvankada
                   -- Bug : 3751069
                   -- Modified the if condition to show the % of Eligible Salary
                    If p_inf_seq In (9,165) Then
                       l_insert_rec := 'Y';
                    elsif p_inf_seq in (7,159,5,164) Then
                        l_insert_rec := 'N';
                    end if;
              Else
                   If p_inf_seq  in (7,159,165,9,5,164) then
                      l_insert_rec := 'N';
                   End if;

              end if;
           End If;
          ----------------------------------
              --  Bug    : 3576954
              --  Author : mvankada
              --  Display Base Salary
              If p_inf_seq = 5 then
                      l_insert_rec := 'Y';
              End if;

          ----------------------------------

          If (l_show_hide_data(l_PLOY_index).p_ws_sub_acty_typ_cd = 'N' And p_inf_seq = 164) then
                hr_utility.set_location( 'Plan is Salary ...',870);
                hr_utility.set_location('(p_inf_seq = 164) :'||p_inf_seq,890);
               l_insert_rec := 'N';
          End if;

End;
End If;
--------------------------------End of Plan Only--------------------------------


--------------------------------Start of Option1 Only--------------------------------

-- Option1
IF (l_OPT1_index <> 0 And l_show_hide_data(l_OPT1_index).p_type = 'OPT1'  ) THEN
Begin
   If l_show_hide_data(l_OPT1_index).p_opt_defined = 'N' then
       hr_utility.set_location( 'Option 1  is not defined...',900);
      -- Disable all Option1 Columns
       Open csr_opt1;
       Fetch csr_opt1 into l_option;
       Close csr_opt1;
       If l_option is not null then
              l_insert_rec := 'N';
       End if;
   Else
       hr_utility.set_location( 'Option 1  is defined...',910);
       -- Option1 Level Checks
              If  l_show_hide_data(l_OPT1_index).p_ws_defined = 'N' And (p_inf_seq  in (30,25,160,166,27) ) then
                  hr_utility.set_location( 'Option 1  worksheet Amount is not  defined...',920);
                  hr_utility.set_location('p_inf_seq : (30,25,160,166,27)'||p_inf_seq,950);
                  l_insert_rec := 'N';
              End if;

              If  l_show_hide_data(l_OPT1_index).p_eligy_sal_defined = 'N' And (p_inf_seq  in (166,27) ) then
                  hr_utility.set_location( 'Option 1  Eligibile Sal is not  defined...',970);
                  hr_utility.set_location('p_inf_seq : (166,27)'||p_inf_seq,1000);
                  l_insert_rec := 'N';
              End if;

          /*    If l_show_hide_data(l_OPT1_index).p_nnmntry_uom = 'Y' And( p_inf_seq  in (25,160,166,27)) then
                  hr_utility.set_location( 'Option 1  is Non Monetory Unit...',1010);
                  hr_utility.set_location('p_inf_seq : (25,160,166,27)'||p_inf_seq,1020);
                  l_insert_rec := 'N';
              End if;
              */
         ----------------------------------
          -- If Option1 is Non-Monetory unit and Eligible Salary is defined then
          -- enable Eligible Salary and
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry

          -- If Option1 is Non-Monetory unit and Eligible Salary is not defined then
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Eligible Salary

           If l_show_hide_data(l_OPT1_index).p_nnmntry_uom = 'Y' Then

              If l_show_hide_data(l_OPT1_index).p_eligy_sal_defined = 'Y' Then
                    If p_inf_seq = 27 Then
                       l_insert_rec := 'Y';
                    elsif p_inf_seq in (25,160,166) Then
                        l_insert_rec := 'N';
                    end if;
              Else
                   If p_inf_seq  in (25,160,166,27) then
                      l_insert_rec := 'N';
                   End if;

              end if;
           End If;
          ----------------------------------
        End If;
 End;
 End If;
 -------------------------------End  of Option1 Only--------------------------------

-- Option2

 -------------------------------Start of Option2 Only--------------------------------
IF (l_OPT2_index <> 0 And l_show_hide_data(l_OPT2_index).p_type = 'OPT2'  ) THEN
Begin
       If l_show_hide_data(l_OPT2_index).p_opt_defined = 'N' then
           -- Disable all Option1 Columns
              Open csr_opt2;
              Fetch csr_opt2 into l_option;
              Close csr_opt2;
              If l_option is not null then
                   l_insert_rec := 'N';
              End if;
         Else
              -- Option1 Level Checks
              If  l_show_hide_data(l_OPT2_index).p_ws_defined = 'N' And (p_inf_seq  in (48,43,161,167,45) ) then
                  l_insert_rec := 'N';
              End if;

              If  l_show_hide_data(l_OPT2_index).p_eligy_sal_defined = 'N' And (p_inf_seq  in (167,45) ) then
                  l_insert_rec := 'N';
              End if;

            /*  If l_show_hide_data(l_OPT2_index).p_nnmntry_uom = 'Y' And( p_inf_seq  in (43,161,167,45)) then
                  l_insert_rec := 'N';
              End if;
              */
         ----------------------------------
          -- If Option2 is Non-Monetory unit and Eligible Salary is defined then
          -- enable Eligible Salary and
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry

          -- If Option2 is Non-Monetory unit and Eligible Salary is not defined then
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Eligible Salary

           If l_show_hide_data(l_OPT2_index).p_nnmntry_uom = 'Y' Then

              If l_show_hide_data(l_OPT2_index).p_eligy_sal_defined = 'Y' Then
                    If p_inf_seq = 45 Then
                       l_insert_rec := 'Y';
                    elsif p_inf_seq in (43,161,167) Then
                        l_insert_rec := 'N';
                    end if;
              Else
                   If p_inf_seq  in (43,161,167,45) then
                      l_insert_rec := 'N';
                   End if;

              end if;
           End If;
          ----------------------------------
          End If;
end;
End If;
 -------------------------------End of Option2 Only--------------------------------
 -- Option3

-------------------------------Start of Option3 Only--------------------------------
 IF (l_OPT3_index <> 0 And l_show_hide_data(l_OPT3_index).p_type = 'OPT3'  ) THEN
 Begin
        If l_show_hide_data(l_OPT3_index).p_opt_defined = 'N' then
           -- Disable all Option1 Columns
              Open csr_opt3;
              Fetch csr_opt3 into l_option;
              Close csr_opt3;
              If l_option is not null then
                   l_insert_rec := 'N';
              End if;
         Else
              -- Option1 Level Checks
              If  l_show_hide_data(l_OPT3_index).p_ws_defined = 'N' And (p_inf_seq  in (66,61,162,168,63) ) then
                  l_insert_rec := 'N';
              End if;

              If  l_show_hide_data(l_OPT3_index).p_eligy_sal_defined = 'N' And (p_inf_seq  in (168,63) ) then
                  l_insert_rec := 'N';
              End if;

           /*   If l_show_hide_data(l_OPT3_index).p_nnmntry_uom = 'Y' And( p_inf_seq  in (61,162,168,63)) then
                  l_insert_rec := 'N';
              End if;
            */
         ----------------------------------
          -- If Option3 is Non-Monetory unit and Eligible Salary is defined then
          -- enable Eligible Salary and
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry

          -- If Option3 is Non-Monetory unit and Eligible Salary is not defined then
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Eligible Salary

           If l_show_hide_data(l_OPT3_index).p_nnmntry_uom = 'Y' Then

              If l_show_hide_data(l_OPT3_index).p_eligy_sal_defined = 'Y' Then
                    If p_inf_seq = 63 Then
                       l_insert_rec := 'Y';
                    elsif p_inf_seq in (61,162,168) Then
                        l_insert_rec := 'N';
                    end if;
              Else
                   If p_inf_seq  in (61,162,168,63) then
                      l_insert_rec := 'N';
                   End if;

              end if;
           End If;
          ----------------------------------
        End If;
end;
End if;

-------------------------------End of Option3 Only--------------------------------


 -------------------------------Start of Option4 Only--------------------------------

IF (l_OPT4_index <> 0 And l_show_hide_data(l_OPT4_index).p_type = 'OPT4'  ) THEN
Begin
      -- Option4
        If l_show_hide_data(l_OPT4_index).p_opt_defined = 'N' then
           -- Disable all Option1 Columns
              Open csr_opt4;
              Fetch csr_opt4 into l_option;
              Close csr_opt4;
              If l_option is not null then
                   l_insert_rec := 'N';
              End if;
         Else
              -- Option1 Level Checks
              If  l_show_hide_data(l_OPT4_index).p_ws_defined = 'N' And (p_inf_seq  in (84,79,163,169,81) ) then
                  l_insert_rec := 'N';
              End if;

              If  l_show_hide_data(l_OPT4_index).p_eligy_sal_defined = 'N' And (p_inf_seq  in (169,81) ) then
                  l_insert_rec := 'N';
              End if;

           /*   If l_show_hide_data(l_OPT4_index).p_nnmntry_uom = 'Y' And( p_inf_seq  in (79,163,169,81)) then
                  l_insert_rec := 'N';
              End if;
              */
         ----------------------------------
          -- If Option4 is Non-Monetory unit and Eligible Salary is defined then
          -- enable Eligible Salary and
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry

          -- If Option4 is Non-Monetory unit and Eligible Salary is not defined then
          -- disable Exchange Rate, Common Currency Rate,% Eligible Salry, Eligible Salary

           If l_show_hide_data(l_OPT4_index).p_nnmntry_uom = 'Y' Then

              If l_show_hide_data(l_OPT4_index).p_eligy_sal_defined = 'Y' Then
                    If p_inf_seq = 81 Then
                       l_insert_rec := 'Y';
                    elsif p_inf_seq in (79,163,169,81) Then
                        l_insert_rec := 'N';
                    end if;
              Else
                   If p_inf_seq  in (79,163,169,81) then
                      l_insert_rec := 'N';
                   End if;

              end if;
           End If;
          ----------------------------------
        End If;

End;
End if;
 -------------------------------End of Option4 Only--------------------------------

 -- If Options Exists then don't display Plan Group Columns
Begin
IF ( (l_OPT1_index <> 0 And l_show_hide_data(l_OPT1_index).p_type = 'OPT1') OR
     (l_OPT2_index <> 0 And l_show_hide_data(l_OPT2_index).p_type = 'OPT2') OR
     (l_OPT3_index <> 0 And l_show_hide_data(l_OPT3_index).p_type = 'OPT3') OR
     (l_OPT4_index <> 0 And l_show_hide_data(l_OPT4_index).p_type = 'OPT4')
   ) THEN
    If p_inf_seq = 130 then
        l_insert_rec := 'N';
    end if;

End if;
End;

return l_insert_rec;
End decide_insert_rec ;

--
--------------------- insert_cwb_layout_cols_row---------------------
--
Procedure insert_cwb_layout_cols_row(p_application_id   In Number,
                                     p_base_layout_code In Varchar2,
                                     p_act_layout_code  In Varchar2,
                                     p_inf_seq          In Number,
                                     p_dis_seq          In Number,
                                     p_group_pl_id      In Number Default Null,
                                     p_lf_evt_ocrd_dt   In Date Default Null
                                     )
IS
CURSOR csr_layout_cols_row
IS
SELECT blc.application_id
       ,blc.layout_code
       ,blc.block_id
       ,blc.interface_app_id
       ,blc.interface_code
       ,blc.interface_seq_num
       ,blc.sequence_num
       ,blc.style
       ,blc.style_class
       ,blc.hint_style
       ,blc.hint_style_class
       ,blc.prompt_style
       ,blc.prompt_style_class
       ,blc.default_type
       ,blc.DEFAULT_VALUE
       ,blc.created_by
       ,blc.last_updated_by
       ,blc.last_update_login
       ,blc.read_only_flag
FROM  bne_layout_cols blc
WHERE blc.application_id    = p_application_id
AND   blc.layout_code       = p_base_layout_code
AND   blc.interface_seq_num = p_inf_seq;

/*cursor csr_interface_cols_row is
select bic.read_only_flag
from bne_interface_cols_b bic,
     bne_layout_cols blc
where blc.application_id    = p_application_id
and   blc.layout_code       = p_base_layout_code
and   blc.interface_seq_num = p_inf_seq
and   bic.sequence_num      = p_inf_seq
and   blc.interface_code    = bic.interface_code;*/

cursor csr_layout_cols_promotion is
select '1'
FROM  bne_layout_cols blc
WHERE blc.application_id    = p_application_id
AND   blc.layout_code       = p_act_layout_code
AND   blc.interface_seq_num = p_inf_seq
AND   blc.interface_seq_num in (152,191,192,105,126);



l_layout_cols_row  csr_layout_cols_row%RowType;
l_layout_cols_promotion  varchar2(1) := null;

l_proc                  Varchar2(72) := 'create_cwb_layout_cols_row';
l_rowid                 VARCHAR2(200);
l_option                VARCHAR2(1);

l_insert_rec            VARCHAR2(1) := 'Y';
l_show_hide_data        p_show_hide_data;
l_read_only_flag        VARCHAR2(1) := NULL;
l_display_width         NUMBER      := NULL;

Begin

hr_utility.set_location('Entering  '||l_proc,10);
hr_utility.set_location('p_group_pl_id :'||p_group_pl_id,20);
hr_utility.set_location('p_lf_evt_ocrd_dt :'||p_lf_evt_ocrd_dt,30);

If substr(p_base_layout_code,1,16) <> 'BEN_CWB_WS_LYT1_'
    AND p_base_layout_code <> 'BEN_CWB_WRK_SHT_BASE_LYT' then
   l_insert_rec := 'Y';
Else
   l_insert_rec :=  decide_insert_rec (p_inf_seq          => p_inf_seq
                      ,p_group_pl_id     => p_group_pl_id
                      ,p_lf_evt_ocrd_dt  => p_lf_evt_ocrd_dt);
End If;
hr_utility.set_location('p_inf_seq #: '||p_inf_seq||'  l_insert_rec #:'||l_insert_rec,60);

OPEN csr_layout_cols_row;
FETCH csr_layout_cols_row  INTO l_layout_cols_row;
if csr_layout_cols_row%NOTFOUND then
 l_insert_rec := 'N';
 hr_utility.set_location('Base Layout Does Not Have Item Checked:'||l_proc, 70);
end if;
CLOSE csr_layout_cols_row;

open csr_layout_cols_promotion;
fetch csr_layout_cols_promotion into l_layout_cols_promotion;
close csr_layout_cols_promotion;
if (l_layout_cols_promotion is not null) then
    l_insert_rec := 'N'; -- layout col already inserted
end if;

If  l_insert_rec = 'Y' then

 IF (substr(p_base_layout_code,1,16) = 'BEN_CWB_WS_LYT1_'
    OR p_base_layout_code = 'BEN_CWB_WRK_SHT_BASE_LYT') THEN
          l_read_only_flag := 'Y';
          --Hide the contextual security keys
          IF (l_layout_cols_row.interface_seq_num IN (158, 189, 194, 195, 196, 198)) then
              l_display_width  := 0;
          --Hide the security keys in lines
          ELSIF (l_layout_cols_row.interface_seq_num IN (130, 131, 132, 133, 134)) then
              l_display_width  := 0;
              l_read_only_flag := 'N';
          --Make non-updateable columns as read-only
          ELSIF (l_layout_cols_row.interface_seq_num IN (3,12,30,48,66,84,151,152,192,191,126) OR
                 l_layout_cols_row.interface_seq_num BETWEEN 200 AND 234 OR
                 -- ER : ability to update other rates and custom segments
                 l_layout_cols_row.interface_seq_num BETWEEN 136 AND 150 OR
                 l_layout_cols_row.interface_seq_num in (165,8,26,44,62,80,10,28,46,64,82,11,29,47,65,83,19,20,21,37,38,39,55,56,57,73,74,75,91,92,93)
           --changed by KMG included the below condition
             OR l_layout_cols_row.interface_seq_num BETWEEN 240 and 244) THEN
              l_read_only_flag := 'N';
          END IF;
	  IF(l_read_only_flag = 'N') THEN
		l_read_only_flag := l_layout_cols_row.read_only_flag;
	/*	IF(l_read_only_flag = 'N') THEN
            for l_interface_cols_row in csr_interface_cols_row loop
                l_read_only_flag := l_interface_cols_row.read_only_flag;
                hr_utility.set_location('p_inf_seq  '||p_inf_seq,10);
                hr_utility.set_location('l_read_only_flag  '||l_read_only_flag,10);
            end loop;
		end if;*/
	  END IF;
  END IF;
  hr_utility.set_location('p_inf_seq  '||p_inf_seq||' l_read_only_flag  '||l_read_only_flag,10);
  bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row.application_id
                ,x_layout_code                => p_act_layout_code
                ,x_block_id                   => l_layout_cols_row.block_id
                ,x_sequence_num               => p_dis_seq
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row.interface_app_id
                ,x_interface_code             => l_layout_cols_row.interface_code
                ,x_interface_seq_num          => l_layout_cols_row.interface_seq_num
                ,x_style_class                => l_layout_cols_row.style_class
                ,x_hint_style                 => l_layout_cols_row.hint_style
                ,x_hint_style_class           => l_layout_cols_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row.prompt_style_class
                ,x_default_type               => l_layout_cols_row.default_type
                ,x_default_value              => l_layout_cols_row.DEFAULT_VALUE
                ,x_style                      => l_layout_cols_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_row.last_update_login
                ,x_read_only_flag             => l_read_only_flag
                ,x_display_width              => l_display_width);
end if;

hr_utility.set_location('Leaving '||l_proc,100);
End insert_cwb_layout_cols_row;

--
--------------------------update_cwb_layout----------------------
--

PROCEDURE update_cwb_layout(
      p_layout_code     IN   VARCHAR2
     ,p_base_layout     IN   VARCHAR2
     ,p_interface_seq   IN   VARCHAR2
     ,p_rendered_seq    IN   VARCHAR2
     ,p_group_pl_id     IN   NUMBER Default Null
     ,p_lf_evt_ocrd_dt  IN   DATE   Default Null
     ,p_download_switch OUT  NOCOPY VARCHAR2
     )    IS

LIST                  column_list := column_list();
list_rec              column_rec;
l_application_id      NUMBER(3) := 800;
l_temp_layout_code    VARCHAR2(100) := p_base_layout;
l_params              VARCHAR2(1000) := p_rendered_seq;
l_interface_seq       VARCHAR2(1000) := p_interface_seq;
l_rowid               VARCHAR2(200);
param_loc             NUMBER(3);
interface_seq_loc     NUMBER(3);
param_len             NUMBER(3) := LENGTH(l_params);
interface_seq_len     NUMBER(3) := LENGTH(l_interface_seq);
param_val             VARCHAR2(1000);
interface_seq_val     VARCHAR2(100);
idx                   NUMBER := 1;
l_pl_ws_amt_switch    VARCHAR(1) := '1';
l_opt1_ws_amt_switch  VARCHAR(1) := '1';
l_opt2_ws_amt_switch  VARCHAR(1) := '1';
l_opt3_ws_amt_switch  VARCHAR(1) := '1';
l_opt4_ws_amt_switch  VARCHAR(1) := '1';
l_perf_switch         VARCHAR(1) := '1';
l_rank_switch         VARCHAR(1) := '1';
l_cpi_attribute1_switch  VARCHAR(1) := '1';
l_cpi_attribute2_switch  VARCHAR(1) := '1';
l_cpi_attribute3_switch  VARCHAR(1) := '1';
l_cpi_attribute4_switch  VARCHAR(1) := '1';
l_cpi_attribute5_switch  VARCHAR(1) := '1';
l_cpi_attribute6_switch  VARCHAR(1) := '1';
l_cpi_attribute7_switch  VARCHAR(1) := '1';
l_cpi_attribute8_switch  VARCHAR(1) := '1';
l_cpi_attribute9_switch  VARCHAR(1) := '1';
l_cpi_attribute10_switch  VARCHAR(1) := '1';
l_cpi_attribute11_switch  VARCHAR(1) := '1';
l_cpi_attribute12_switch  VARCHAR(1) := '1';
l_cpi_attribute13_switch  VARCHAR(1) := '1';
l_cpi_attribute14_switch  VARCHAR(1) := '1';
l_cpi_attribute15_switch  VARCHAR(1) := '1';
l_cpi_attribute16_switch  VARCHAR(1) := '1';
l_cpi_attribute17_switch  VARCHAR(1) := '1';
l_cpi_attribute18_switch  VARCHAR(1) := '1';
l_cpi_attribute19_switch  VARCHAR(1) := '1';
l_cpi_attribute20_switch  VARCHAR(1) := '1';
l_cpi_attribute21_switch  VARCHAR(1) := '1';
l_cpi_attribute22_switch  VARCHAR(1) := '1';
l_cpi_attribute23_switch  VARCHAR(1) := '1';
l_cpi_attribute24_switch  VARCHAR(1) := '1';
l_cpi_attribute25_switch  VARCHAR(1) := '1';
l_cpi_attribute26_switch  VARCHAR(1) := '1';
l_cpi_attribute27_switch  VARCHAR(1) := '1';
l_cpi_attribute28_switch  VARCHAR(1) := '1';
l_cpi_attribute29_switch  VARCHAR(1) := '1';
l_cpi_attribute30_switch  VARCHAR(1) := '1';
l_promotion_switch        VARCHAR(1) := '1';
l_pl_other_rates_switch   VARCHAR(1) := '1';
l_opt1_other_rates_switch VARCHAR(1) := '1';
l_opt2_other_rates_switch VARCHAR(1) := '1';
l_opt3_other_rates_switch VARCHAR(1) := '1';
l_opt4_other_rates_switch VARCHAR(1) := '1';


CURSOR c_layout_cols( v_application_id   IN   NUMBER
                     ,v_layout_code      IN   VARCHAR2)
IS
SELECT  blc.application_id
       ,blc.layout_code
       ,blc.block_id
       ,blc.sequence_num
FROM   bne_layout_cols blc
WHERE  blc.application_id = v_application_id
AND    blc.layout_code = v_layout_code;

CURSOR c_layout_cols_row(
         v_interface_seq    IN   NUMBER
        ,v_application_id   IN   NUMBER
        ,v_layout_code      IN   VARCHAR2)   IS
SELECT blc.application_id
               ,blc.layout_code
               ,blc.block_id
               ,blc.interface_app_id
               ,blc.interface_code
               ,blc.interface_seq_num
               ,blc.sequence_num
               ,blc.style
               ,blc.style_class
               ,blc.hint_style
               ,blc.hint_style_class
               ,blc.prompt_style
               ,blc.prompt_style_class
               ,blc.default_type
               ,blc.DEFAULT_VALUE
               ,blc.created_by
               ,blc.last_updated_by
               ,blc.last_update_login
FROM  bne_layout_cols blc
WHERE blc.application_id = v_application_id
AND   blc.layout_code = v_layout_code
AND   blc.interface_seq_num = v_interface_seq;

l_layout_cols_row c_layout_cols_row%ROWTYPE;
l_layout_col_rec c_layout_cols%ROWTYPE;
BEGIN

      LOOP
         param_loc := INSTR(l_params, '+');
         interface_seq_loc := INSTR(l_interface_seq, '+');
         param_val := SUBSTR(l_params, 1, param_loc - 1);
         interface_seq_val := SUBSTR(l_interface_seq, 1, interface_seq_loc - 1);

         IF param_loc = 0  THEN
            param_val := l_params;
         END IF;

         IF interface_seq_loc = 0  THEN
            interface_seq_val := l_interface_seq;
         END IF;

         l_params        := SUBSTR(l_params, param_loc + 1, param_len);
         l_interface_seq :=  SUBSTR(l_interface_seq, interface_seq_loc + 1, interface_seq_len);
         If g_debug then
          hr_utility.set_location('parameter : '||param_val||' '||interface_seq_val,20);
         END IF;
         LIST.EXTEND;
         list_rec.p_sequence := TO_NUMBER(param_val);
         list_rec.p_interface_seq := TO_NUMBER(interface_seq_val);
         LIST(idx) := list_rec;

         EXIT WHEN param_loc = 0;
         idx := idx + 1;
      END LOOP;

      delete_cwb_layout_cols(p_layout_code     => p_layout_code
                            ,p_application_id  => l_application_id);

/*      BEGIN
         OPEN c_layout_cols(l_application_id, p_layout_code);

         LOOP
            FETCH c_layout_cols  INTO l_layout_col_rec;
            EXIT WHEN c_layout_cols%NOTFOUND;

            -- DBMS_OUTPUT.put_line('## Seq Num :'||l_layout_col_rec.sequence_num);
            hr_utility.set_location('Seq Num :'||l_layout_col_rec.sequence_num,25);
            bne_layout_cols_pkg.delete_row
                         (x_application_id      => l_layout_col_rec.application_id
                         ,x_layout_code         => l_layout_col_rec.layout_code
                         ,x_block_id            => l_layout_col_rec.block_id
                         ,x_sequence_num        => l_layout_col_rec.sequence_num);
         END LOOP;

         CLOSE c_layout_cols;
      EXCEPTION
         WHEN OTHERS
         THEN
            Null;
            hr_utility.set_location('ERROR occured',30);
            -- DBMS_OUTPUT.put_line('ERROR WHILE DELETING');
      END;
*/


      FOR k IN LIST.FIRST .. LIST.LAST
      LOOP
         IF (LIST(k).p_sequence <> 0)  THEN

	       IF(LIST(k).p_interface_seq = 12) THEN
	             l_pl_ws_amt_switch    := '2';
		   ELSIF(LIST(k).p_interface_seq = 30) THEN
	             l_opt1_ws_amt_switch  := '2';
		   ELSIF(LIST(k).p_interface_seq = 48) THEN
	             l_opt2_ws_amt_switch  := '2';
		   ELSIF(LIST(k).p_interface_seq = 66) THEN
	             l_opt3_ws_amt_switch  := '2';
		   ELSIF(LIST(k).p_interface_seq = 84) THEN
	             l_opt4_ws_amt_switch  := '2';
		   ELSIF(LIST(k).p_interface_seq = 151) THEN
	             l_perf_switch         := '2';
		   ELSIF(LIST(k).p_interface_seq = 3) THEN
	             l_rank_switch         := '2';
	       ELSIF(LIST(k).p_interface_seq = 200) THEN
	             l_cpi_attribute1_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 201) THEN
	             l_cpi_attribute2_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 202) THEN
	             l_cpi_attribute3_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 203) THEN
	             l_cpi_attribute4_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 204) THEN
	             l_cpi_attribute5_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 205) THEN
	             l_cpi_attribute6_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 206) THEN
	             l_cpi_attribute7_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 207) THEN
	             l_cpi_attribute8_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 208) THEN
	             l_cpi_attribute9_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 209) THEN
	             l_cpi_attribute10_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 210) THEN
	             l_cpi_attribute11_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 211) THEN
	             l_cpi_attribute12_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 212) THEN
	             l_cpi_attribute13_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 213) THEN
	             l_cpi_attribute14_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 214) THEN
	             l_cpi_attribute15_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 215) THEN
	             l_cpi_attribute16_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 216) THEN
	             l_cpi_attribute17_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 217) THEN
	             l_cpi_attribute18_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 218) THEN
	             l_cpi_attribute19_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 219) THEN
	             l_cpi_attribute20_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 220) THEN
	             l_cpi_attribute21_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 221) THEN
	             l_cpi_attribute22_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 222) THEN
	             l_cpi_attribute23_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 223) THEN
	             l_cpi_attribute24_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 224) THEN
	             l_cpi_attribute25_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 225) THEN
	             l_cpi_attribute26_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 226) THEN
	             l_cpi_attribute27_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 227) THEN
	             l_cpi_attribute28_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 228) THEN
	             l_cpi_attribute29_switch  := '2';
	       ELSIF(LIST(k).p_interface_seq = 229) THEN
	             l_cpi_attribute30_switch  := '2';
           ELSIF(LIST(k).p_interface_seq in (126,152,191,192) ) THEN
                 l_promotion_switch        := '2';
           ELSIF(LIST(k).p_interface_seq in (8,10,11,19,20,21) ) THEN
		     l_pl_other_rates_switch   := '2';
	       ELSIF(LIST(k).p_interface_seq in (26,28,29,37,38,39) ) THEN
		     l_opt1_other_rates_switch := '2';
	       ELSIF(LIST(k).p_interface_seq in (44,46,47,55,56,57) ) THEN
		     l_opt2_other_rates_switch   := '2';
	       ELSIF(LIST(k).p_interface_seq in (62,64,65,73,74,75) ) THEN
		     l_opt3_other_rates_switch   := '2';
	       ELSIF(LIST(k).p_interface_seq in (80,82,83,91,92,931) ) THEN
		 l_opt4_other_rates_switch   := '2';
           END IF;

         insert_cwb_layout_cols_row( p_application_id    => l_application_id
                                     ,p_base_layout_code => p_base_layout
                                     ,p_act_layout_code  => p_layout_code
                                     ,p_inf_seq          => LIST(k).p_interface_seq
                                     ,p_dis_seq          => LIST(k).p_sequence
                                     ,p_group_pl_id      => p_group_pl_id
                                     ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt );
          /*  OPEN c_layout_cols_row(LIST(k).p_interface_seq
                                  ,l_application_id
                                  ,l_temp_layout_code);

            FETCH c_layout_cols_row  INTO l_layout_cols_row;
            CLOSE c_layout_cols_row;

            -- DBMS_OUTPUT.put_line('Sequence :'||LIST(k).p_sequence ||'Inf Seq  :'|| l_layout_cols_row.interface_seq_num);

            hr_utility.set_location('Sequence :'||LIST(k).p_sequence||'Inf Seq  : '||l_layout_cols_row.interface_seq_num ,50);
            bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row.application_id
                ,x_layout_code                => p_layout_code
                ,x_block_id                   => l_layout_cols_row.block_id
                ,x_sequence_num               => LIST(k).p_sequence
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row.interface_app_id
                ,x_interface_code             => l_layout_cols_row.interface_code
                ,x_interface_seq_num          => l_layout_cols_row.interface_seq_num
                ,x_style_class                => l_layout_cols_row.style_class
                ,x_hint_style                 => l_layout_cols_row.hint_style
                ,x_hint_style_class           => l_layout_cols_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row.prompt_style_class
                ,x_default_type               => l_layout_cols_row.default_type
                ,x_default_value              => l_layout_cols_row.DEFAULT_VALUE
                ,x_style                      => l_layout_cols_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_row.last_update_login);
                */
         END IF;
      END LOOP;
       p_download_switch := '2' ||
                            l_pl_ws_amt_switch||
                            l_opt1_ws_amt_switch||
                            l_opt2_ws_amt_switch||
                            l_opt3_ws_amt_switch||
                            l_opt4_ws_amt_switch||
                            l_perf_switch||
                            l_rank_switch||
                            l_cpi_attribute1_switch||
                            l_cpi_attribute2_switch||
                            l_cpi_attribute3_switch||
                            l_cpi_attribute4_switch||
                            l_cpi_attribute5_switch||
                            l_cpi_attribute6_switch||
                            l_cpi_attribute7_switch||
                            l_cpi_attribute8_switch||
                            l_cpi_attribute9_switch||
                            l_cpi_attribute10_switch||
                            l_cpi_attribute11_switch||
                            l_cpi_attribute12_switch||
                            l_cpi_attribute13_switch||
                            l_cpi_attribute14_switch||
                            l_cpi_attribute15_switch||
                            l_cpi_attribute16_switch||
                            l_cpi_attribute17_switch||
                            l_cpi_attribute18_switch||
                            l_cpi_attribute19_switch||
                            l_cpi_attribute20_switch||
                            l_cpi_attribute21_switch||
                            l_cpi_attribute22_switch||
                            l_cpi_attribute23_switch||
                            l_cpi_attribute24_switch||
                            l_cpi_attribute25_switch||
                            l_cpi_attribute26_switch||
                            l_cpi_attribute27_switch||
                            l_cpi_attribute28_switch||
                            l_cpi_attribute29_switch||
                            l_cpi_attribute30_switch||
                            l_promotion_switch||
                            l_pl_other_rates_switch||
                            l_opt1_other_rates_switch||
                            l_opt2_other_rates_switch||
                            l_opt3_other_rates_switch||
                            l_opt4_other_rates_switch;

   p_download_switch := REPLACE(REPLACE(p_download_switch,'1','0'),'2','1');
   p_download_switch := nvl(lpad(int2hex(bin2int(substr(p_download_switch,1,28))),7,0)||
                        int2hex(bin2int(rpad(substr(p_download_switch,29),28,0))),'0000000');
END update_cwb_layout;

--
--------------------------encrypt----------------------
--

FUNCTION encrypt(
      input_string   IN   VARCHAR2)
      RETURN VARCHAR2
IS
      l_encrypted_string VARCHAR2(2048);
BEGIN
l_encrypted_string := NULL;
DBMS_OBFUSCATION_TOOLKIT.des3encrypt (input_string          => input_string
                                      ,key_string            => key_string
                                      ,encrypted_string      => l_encrypted_string);

RETURN rawtohex(UTL_RAW.CAST_TO_RAW(l_encrypted_string));
END;

--
--------------------------decrypt----------------------
--
FUNCTION decrypt( input_string   IN   VARCHAR2) RETURN VARCHAR2
IS
l_decrypted_string VARCHAR2(2048);
l_convert_string   VARCHAR2(2048);
BEGIN
      l_convert_string := hextoraw(input_string);
      l_convert_string := UTL_RAW.CAST_TO_VARCHAR2(input_string);

      l_decrypted_string := NULL;
      DBMS_OBFUSCATION_TOOLKIT.des3decrypt
                                        (input_string          => l_convert_string
                                        ,key_string            => key_string
                                        ,decrypted_string      => l_decrypted_string);
      RETURN l_decrypted_string;
END;
--
--------------------------lock_cwb_layout----------------------
--
FUNCTION lock_cwb_layout(p_integrator_code IN Varchar2
                        ,p_base_layout_code IN VARCHAR2)
      RETURN VARCHAR2
IS
CURSOR c_layout  IS
SELECT layout_code
FROM   bne_layouts_b
WHERE  integrator_code = p_integrator_code
AND    integrator_app_id = 800
AND    application_id    = 800
AND    layout_code  <> p_base_layout_code
AND    layout_code NOT IN (SELECT attribute1
                             FROM ben_transaction
                            WHERE transaction_type = 'CWBWEBADI'
                              AND attribute2 IS NOT NULL
                              AND attribute1 IS NOT NULL
                              AND DECODE(transaction_type, 'CWBWEBADI', SYSDATE - (to_number(l_layout_lock_time) /(24 * 60))
                                 - TO_DATE(attribute2, 'yyyy/mm/dd:hh:mi'),0) < 0);

l_layout               VARCHAR2(200);
l_new_layout_user_name Varchar2(4000);
l_date                 Varchar2(100);
BEGIN
      OPEN c_layout;
      FETCH c_layout INTO l_layout;
      CLOSE c_layout;

 IF l_layout IS NULL  THEN
      BEGIN
        l_date        := to_char(sysdate,'yyyymmddhhmi');
        l_layout      :=  '__'||to_char(sysdate,'yyyymmddhhmi')||'__';
        l_new_layout_user_name :=  '__'||to_char(sysdate,'yyyymmddhhmi')||'__';
        create_cwb_layout( p_layout_code      => l_layout
                          ,p_user_name        => l_new_layout_user_name
                          ,p_base_layout_code => p_base_layout_code);

      END;
 ELSE
      BEGIN
            DELETE  ben_transaction
            WHERE   transaction_type = 'CWBWEBADI'
            AND attribute1 = l_layout;
      EXCEPTION
            WHEN OTHERS THEN
               NULL;
      END;

      INSERT INTO ben_transaction
                     (transaction_id
                     ,transaction_type
                     ,attribute1
                     ,attribute2)
      VALUES (ben_transaction_s.NEXTVAL
                     ,'CWBWEBADI'
                     ,l_layout
                     ,TO_CHAR(SYSDATE, 'yyyy/mm/dd:hh:mi'));
END IF;



      RETURN l_layout;

END;
--
--------------------------unlock_cwb_layout----------------------
--

PROCEDURE unlock_cwb_layout( p_layout_code   IN   VARCHAR2)
IS
BEGIN
      DELETE   ben_transaction
      WHERE    transaction_type = 'CWBWEBADI'
      AND      attribute1 = p_layout_code;
EXCEPTION
      WHEN OTHERS  THEN
         NULL;
   END;

--
-------------------------- create_custom_row ----------------------
--
Procedure create_custom_row (  p_key                IN   VARCHAR2
                              ,p_region_key         IN   VARCHAR2
                              ,p_integrator_code    IN   VARCHAR2
                              ,p_interface_code     IN   VARCHAR2
                              ,p_interface_col_code IN   VARCHAR2
                              ,p_display_seq        IN   Number)
IS

Cursor csr_col_prompt
IS
Select InfColsTl.prompt_left
From  bne_interface_cols_b InfCols,
      bne_interface_cols_tl InfColsTl
Where InfCols.interface_code     = p_interface_code
And   InfCols.INTERFACE_COL_NAME = p_interface_col_code
And   InfCols.application_id = 800
And   InfCols.interface_code = InfColsTl.interface_code
And   InfCols.sequence_num  = InfColsTl.sequence_num
And   InfColsTl.application_id = 800
And   InfColsTl.Language = Userenv('LANG');

l_proc         Varchar2(72) := g_package||'create_custom_row';
l_col_prompt   bne_interface_cols_tl.prompt_left%Type;

Begin
   if g_debug then
      hr_utility.set_location('Entering '||l_proc,10);
      hr_utility.set_location('p_key               :'||p_key,30);
      hr_utility.set_location('p_integrator_code   :'||p_integrator_code,40);
      hr_utility.set_location('p_interface_code    :'||p_interface_code,50);
   end if;

   Open csr_col_prompt;
   Fetch csr_col_prompt into l_col_prompt;
   Close csr_col_prompt;


     Insert Into BEN_CUSTOM_REGION_ITEMS
         (
           REGION_CODE     -- task code / integrator code
          ,CUSTOM_KEY      -- mgr_per_in_ler_id
          ,CUSTOM_TYPE     -- integrator code
          ,ITEM_NAME       -- interface_col_name
          ,DISPLAY_FLAG    -- Y/N
          ,LABEL           -- interface_prompt_above
          ,ORDR_NUM        -- Display Order
         )
     Values
      (
          p_region_key --p_integrator_code         -- task code / integrator code
         ,p_key                     -- mgr_per_in_ler_id
         ,p_integrator_code         -- integrator code
         ,p_interface_col_code      -- interface_col_name
         ,'N'
         ,l_col_prompt  -- interface_prompt_above
         ,p_display_seq           -- Display Order
       );

hr_utility.set_location('Entering '||l_proc,10);
Exception
     When Others then
         hr_utility.set_location('Error :'||substr(sqlerrm,1,50),100);
         hr_utility.set_location('Error :'||substr(sqlerrm,51,100),110);
         raise;

End create_custom_row;

--
--------------------------chk_entry_in_custom_table----------------------
--
/* Purpose :
     This function checks whether data exists in table BEN_CUSTOM_REGION_ITEMS or not.
     If data exists in the table then returns 'Y' else 'N'
*/

Function chk_entry_in_custom_table(  p_key              IN   VARCHAR2
                                    ,p_region_key         IN   VARCHAR2
                                    ,p_integrator_code  IN   VARCHAR2
                                     ) Return Varchar
IS
Cursor  Csr_entry
IS
Select  '1'
From    BEN_CUSTOM_REGION_ITEMS
Where   CUSTOM_TYPE = p_integrator_code
And     REGION_CODE = p_region_key
And     CUSTOM_KEY  = p_key;

l_exists     Varchar2(1);
l_return_val Varchar2(1) := 'N';
l_proc       Varchar2(72) := g_package||'chk_entry_in_custom_table';

BEGIN
      hr_utility.set_location('Entering '||l_proc,10);

     Open  Csr_entry;
     Fetch Csr_entry into l_exists;
     Close Csr_entry;

     -- If entires are not there insert data into table BEN_CUSTOM_REGION_ITEMS
     If l_exists is null then
          l_return_val := 'N';
     Else
          l_return_val := 'Y';
     End if;

     hr_utility.set_location('Entry Exists (Y/N) : '||l_return_val,100);
     hr_utility.set_location('Leaving '||l_proc,200);

     return l_return_val;

EXCEPTION
      WHEN OTHERS  THEN
   hr_utility.set_location('Error :'||substr(sqlerrm,1,50),100);
         hr_utility.set_location('Error :'||substr(sqlerrm,51,100),110);
         return 'N';

END chk_entry_in_custom_table;

--
--------------------------manipulate_seleted_data----------------------
--


Procedure manipulate_selected_data( p_key               IN   VARCHAR2
                               ,p_region_key         IN   VARCHAR2
                               ,p_integrator_code       IN   VARCHAR2
                               ,p_interface_code        IN   VARCHAR2
                               ,p_interface_col_code    IN   VARCHAR2
                               ,p_display_seq           IN Number )
IS


l_proc             Varchar2(72) := g_package||'chk_entry_in_custom_table';


Begin
hr_utility.set_location('Entering '||l_proc,10);

-- If data not exists in the Custom Table insert data


     create_custom_row( p_key               =>  p_key
                       ,p_region_key        =>  p_region_key
                       ,p_integrator_code   =>  p_integrator_code
                       ,p_interface_code    =>  p_interface_code
                       ,p_interface_col_code => p_interface_col_code
                       ,p_display_seq        => p_display_seq);

 hr_utility.set_location('Leaving '||l_proc,200);
EXCEPTION
      WHEN OTHERS  THEN
         hr_utility.set_location('Error :'||substr(sqlerrm,1,50),100);
         hr_utility.set_location('Error :'||substr(sqlerrm,51,100),110);
         raise;
End manipulate_selected_data;

--
----------------------delete_custom_data ---------------------------
--
Procedure  delete_custom_data(p_key                 IN VARCHAR2,
                              p_region_key         IN   VARCHAR2,
                              p_integrator_code     IN VARCHAR2)
IS
l_exist_in_table   Varchar2(1);
BEGIN
l_exist_in_table := chk_entry_in_custom_table(  p_key              => p_key
                                               ,p_region_key       => p_region_key
                                               ,p_integrator_code  => p_integrator_code);

hr_utility.set_location('l_exist_in_table :'||l_exist_in_table,20);


If l_exist_in_table = 'Y' Then
    hr_utility.set_location('Data Not exists in custom Table ',25);
     Delete From   BEN_CUSTOM_REGION_ITEMS
           Where   CUSTOM_KEY   = p_key
             And   REGION_CODE  = p_region_key
             And   CUSTOM_TYPE  = p_integrator_code;
End If;
END;

--
--------------------- update_cwb_custom_layout ---------------------
--

Procedure  update_cwb_custom_layout( p_key          IN   VARCHAR2
                               ,p_region_key         IN   VARCHAR2
                               ,p_integrator_code   IN   VARCHAR2
                               ,p_interface_code    IN   VARCHAR2
                               ,p_act_layout_code   IN   VARCHAR2
                               ,p_base_layout_code  IN   VARCHAR2
                               ,p_group_pl_id       IN NUMBER Default Null
                               ,p_lf_evt_ocrd_dt    IN DATE   Default Null
                               ,p_download_switch OUT  NOCOPY VARCHAR2
                               )
IS
l_num NUMBER := 0;
l_pl_ws_amt_switch    VARCHAR(1) := '1';
l_opt1_ws_amt_switch  VARCHAR(1) := '1';
l_opt2_ws_amt_switch  VARCHAR(1) := '1';
l_opt3_ws_amt_switch  VARCHAR(1) := '1';
l_opt4_ws_amt_switch  VARCHAR(1) := '1';
l_perf_switch         VARCHAR(1) := '1';
l_rank_switch         VARCHAR(1) := '1';
l_cpi_attribute1_switch  VARCHAR(1) := '1';
l_cpi_attribute2_switch  VARCHAR(1) := '1';
l_cpi_attribute3_switch  VARCHAR(1) := '1';
l_cpi_attribute4_switch  VARCHAR(1) := '1';
l_cpi_attribute5_switch  VARCHAR(1) := '1';
l_cpi_attribute6_switch  VARCHAR(1) := '1';
l_cpi_attribute7_switch  VARCHAR(1) := '1';
l_cpi_attribute8_switch  VARCHAR(1) := '1';
l_cpi_attribute9_switch  VARCHAR(1) := '1';
l_cpi_attribute10_switch  VARCHAR(1) := '1';
l_cpi_attribute11_switch  VARCHAR(1) := '1';
l_cpi_attribute12_switch  VARCHAR(1) := '1';
l_cpi_attribute13_switch  VARCHAR(1) := '1';
l_cpi_attribute14_switch  VARCHAR(1) := '1';
l_cpi_attribute15_switch  VARCHAR(1) := '1';
l_cpi_attribute16_switch  VARCHAR(1) := '1';
l_cpi_attribute17_switch  VARCHAR(1) := '1';
l_cpi_attribute18_switch  VARCHAR(1) := '1';
l_cpi_attribute19_switch  VARCHAR(1) := '1';
l_cpi_attribute20_switch  VARCHAR(1) := '1';
l_cpi_attribute21_switch  VARCHAR(1) := '1';
l_cpi_attribute22_switch  VARCHAR(1) := '1';
l_cpi_attribute23_switch  VARCHAR(1) := '1';
l_cpi_attribute24_switch  VARCHAR(1) := '1';
l_cpi_attribute25_switch  VARCHAR(1) := '1';
l_cpi_attribute26_switch  VARCHAR(1) := '1';
l_cpi_attribute27_switch  VARCHAR(1) := '1';
l_cpi_attribute28_switch  VARCHAR(1) := '1';
l_cpi_attribute29_switch  VARCHAR(1) := '1';
l_cpi_attribute30_switch  VARCHAR(1) := '1';
l_promotion_switch  VARCHAR(1) := '1';
l_pl_other_rates_switch   VARCHAR(1) := '1';
l_opt1_other_rates_switch VARCHAR(1) := '1';
l_opt2_other_rates_switch VARCHAR(1) := '1';
l_opt3_other_rates_switch VARCHAR(1) := '1';
l_opt4_other_rates_switch VARCHAR(1) := '1';

Cursor csr_bne_data
IS
Select  infCols.interface_col_name inf_col_name
       ,infCols.sequence_num       inf_Seq_Num
       ,layCols.SEQUENCE_NUM       Dis_Seq_Num
From    bne_interfaces_b      inf,
        bne_interface_cols_b  infCols,
        bne_layout_cols       layCols,
        bne_layout_blocks_b   layBlk
Where   inf.integrator_code    = p_integrator_code
And     inf.integrator_app_id  = 800
And     inf.interface_code     = p_interface_code
And     inf.application_id     = 800
And     inf.interface_code     = infCols.interface_code
And     infCols.application_id = 800
And     infCols.sequence_num   = layCols.INTERFACE_SEQ_NUM
And     layCols.layout_code    = p_base_layout_code
And     layCols.application_id = 800
And     layCols.layout_code    = layBlk.layout_code
And     layCols.block_id       = layBlk.block_id
And     layBlk.STYLE_CLASS     = 'BNE_LINES'
And     layBlk.application_id  = 800;

Cursor csr_cust_data
IS
Select   cust.ITEM_NAME               inf_col_name
        ,infCols.SEQUENCE_NUM         inf_Seq_Num
        ,cust.ORDR_NUM                Dis_Seq_Num
From    BEN_CUSTOM_REGION_ITEMS cust,
        Bne_interface_cols_b    infCols
Where   cust.CUSTOM_KEY  = p_key
And     cust.REGION_CODE = p_region_key --p_integrator_code
And     cust.CUSTOM_TYPE = p_integrator_code
And     cust.ITEM_NAME   = infCols.INTERFACE_COL_NAME
And     infCols.interface_code = p_interface_code
And     infCols.application_id = 800;



cursor do_not_disturb is
select interface_seq_num inf_Seq_Num,
       2000+rownum       Dis_Seq_Num
  from bne_layout_cols
 where interface_seq_num in (130,131,132,133,134)
   and layout_code = p_base_layout_code
   and interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and application_id = 800;

cursor group_pl_key is
select decode (col1.interface_seq_num, 7, 1,
               159,2,
               165,3,
               9,4,
               5,5,
               164,6
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (7,159,165,9,5,164)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col1.application_id = 800
   and col1.interface_code = col2.interface_code
   and col2.application_id = 800
   and col2.interface_seq_num = 12
   and col2.layout_code = p_act_layout_code
   order by 1;

cursor group_opt1_key is
select decode (col1.interface_seq_num, 25, 1,
               160,2,
               166,3,
               27,4
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (25,160,166,27)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 30
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_opt2_key is
select decode (col1.interface_seq_num, 43, 1,
               161,2,
               167,3,
               45,4
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (43,161,167,45)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 48
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_opt3_key is
select decode (col1.interface_seq_num, 61, 1,
               162,2,
               168,3,
               63,4
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (61,162,168,63)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 66
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_opt4_key is
select decode (col1.interface_seq_num, 79, 1,
               163,2,
               169,3,
               81,4
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (79,163,169,81)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 84
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_rank_key is
select decode (col1.interface_seq_num, 125, 1,
               197,2
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (125,197)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 3
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

 cursor group_grade_key is
select decode (col1.interface_seq_num,
               126,1,
               105,2
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (105,126)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 191
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_job_key is
select decode (col1.interface_seq_num,
               192,1,
               126,2,
               105,3
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (105,192,126)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 152
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

cursor group_position_key is
select decode (col1.interface_seq_num,
               152,1,
               126,2,
               105,3
              ),
       col1.interface_seq_num inf_Seq_Num, col2.sequence_num  Dis_Seq_Num
  from bne_layout_cols col1,
       bne_layout_cols col2
 where col1.interface_seq_num in (105,152,126)
   and col1.layout_code = p_base_layout_code
   and col1.interface_code = col2.interface_code
   and col2.interface_seq_num = 192
   and col2.interface_code = p_interface_code
   and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
   and col2.layout_code = p_act_layout_code
   and col1.application_id = 800
   and col2.application_id = 800
   order by 1;

Cursor add_cols IS
(Select interface_seq_num  inf_Seq_Num
       , sequence_num      Dis_Seq_Num
       , decode (interface_seq_num, 170, 1,
               171,2,
               172,3,
               173,4,
               174,5,
               175,6,
               176,7,
               177,8,
               178,9,
               179,10,
               180,11,
               181,12,
               182,13,
               189,14,
               158,15,
               194,16,
               195,17,
               196,18,
               198,19,
               188,20,
               190,21
              )  order_in_layout
  From   bne_layout_cols
 Where  interface_code = p_interface_code
  and (substr(p_interface_code,1,15) = 'BEN_CWB_WS_INTF'
   OR p_interface_code = 'BEN_CWB_WRK_SHT_INTF')
  And   interface_seq_num in (170,171,172,173,174,175,176,177,178,179,180,181,182,189,158,188,190,194,195,196,198)
  And   layout_code = p_base_layout_code
  And   application_id = 800)
 union
 (Select interface_seq_num    inf_Seq_Num
         ,sequence_num        Dis_Seq_Num
         , interface_seq_num  order_in_layout
  From   bne_layout_cols
 Where  interface_code = p_interface_code
  And   p_interface_code = 'BEN_CWB_BGT_SHT_INTF'
  And   interface_seq_num in (37,40,41,42,43,44,45,46,47,48,49,50,51,52,53)
  And   layout_code = p_base_layout_code
  And   application_id = 800
 )
  union
  (Select interface_seq_num    inf_Seq_Num
          ,sequence_num        Dis_Seq_Num
          , interface_seq_num  order_in_layout
   From   bne_layout_cols
  Where  interface_code = p_interface_code
   And   p_interface_code = 'BEN_CWB_SUMM_DIR_REP_INTF'
   And   interface_seq_num in (16,17,18,19,20,21,22,23,24,25,26,27,28,29,30)
   And   layout_code = p_base_layout_code
   And   application_id = 800
 )  Order by 3 ;
l_application_id   Number := 800;
l_exist_in_table   Varchar2(1);
l_proc             Varchar2(72) := g_package||'update_cwb_custom_layout';

BEGIN
If g_debug then
 hr_utility.set_location('Entering '||l_proc,10);
End if;
g_interface_code := p_interface_code;
--
delete_cwb_layout_cols(p_layout_code     => p_act_layout_code
                      ,p_application_id  => 800);

l_exist_in_table := chk_entry_in_custom_table(  p_key              => p_key
                                               ,p_region_key       => p_region_key
                                               ,p_integrator_code  => p_integrator_code);
If g_debug then
 hr_utility.set_location('l_exist_in_table :'||l_exist_in_table,20);
End if;

-- If data not exists in the custom table
If l_exist_in_table = 'N' Then
    For l_bne_row In csr_bne_data
    Loop

           IF(l_bne_row.inf_Seq_Num = 12) THEN
	             l_pl_ws_amt_switch    := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 30) THEN
	             l_opt1_ws_amt_switch  := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 48) THEN
	             l_opt2_ws_amt_switch  := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 66) THEN
	             l_opt3_ws_amt_switch  := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 84) THEN
	             l_opt4_ws_amt_switch  := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 151) THEN
	             l_perf_switch         := '2';
		   ELSIF(l_bne_row.inf_Seq_Num = 3) THEN
	             l_rank_switch         := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 200) THEN
	             l_cpi_attribute1_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 201) THEN
	             l_cpi_attribute2_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 202) THEN
	             l_cpi_attribute3_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 203) THEN
	             l_cpi_attribute4_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 204) THEN
	             l_cpi_attribute5_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 205) THEN
	             l_cpi_attribute6_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 206) THEN
	             l_cpi_attribute7_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 207) THEN
	             l_cpi_attribute8_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 208) THEN
	             l_cpi_attribute9_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 209) THEN
	             l_cpi_attribute10_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 210) THEN
	             l_cpi_attribute11_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 211) THEN
	             l_cpi_attribute12_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 212) THEN
	             l_cpi_attribute13_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 213) THEN
	             l_cpi_attribute14_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 214) THEN
	             l_cpi_attribute15_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 215) THEN
	             l_cpi_attribute16_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 216) THEN
	             l_cpi_attribute17_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 217) THEN
	             l_cpi_attribute18_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 218) THEN
	             l_cpi_attribute19_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 219) THEN
	             l_cpi_attribute20_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 220) THEN
	             l_cpi_attribute21_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 221) THEN
	             l_cpi_attribute22_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 222) THEN
	             l_cpi_attribute23_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 223) THEN
	             l_cpi_attribute24_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 224) THEN
	             l_cpi_attribute25_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 225) THEN
	             l_cpi_attribute26_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 226) THEN
	             l_cpi_attribute27_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 227) THEN
	             l_cpi_attribute28_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 228) THEN
	             l_cpi_attribute29_switch  := '2';
	       ELSIF(l_bne_row.inf_Seq_Num = 229) THEN
	             l_cpi_attribute30_switch  := '2';
           ELSIF(l_bne_row.inf_Seq_Num in (126,152,191,192) ) THEN
                 l_promotion_switch        := '2';
           ELSIF(l_bne_row.inf_Seq_Num in (8,10,11,19,20,21) ) THEN
		     l_pl_other_rates_switch   := '2';
	       ELSIF(l_bne_row.inf_Seq_Num in (26,28,29,37,38,39) ) THEN
		     l_opt1_other_rates_switch := '2';
	       ELSIF(l_bne_row.inf_Seq_Num in (44,46,47,55,56,57) ) THEN
		     l_opt2_other_rates_switch   := '2';
	       ELSIF(l_bne_row.inf_Seq_Num in (62,64,65,73,74,75) ) THEN
		     l_opt3_other_rates_switch   := '2';
	       ELSIF(l_bne_row.inf_Seq_Num in (80,82,83,91,92,931) ) THEN
		      l_opt4_other_rates_switch   := '2';
           END IF;


        insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_bne_row.inf_Seq_Num
                                ,p_dis_seq          => l_bne_row.Dis_Seq_Num * 10
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
    End Loop;
Else
     For l_cust_row In csr_cust_data
     Loop
           IF(l_cust_row.inf_Seq_Num = 12) THEN
	             l_pl_ws_amt_switch    := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 30) THEN
	             l_opt1_ws_amt_switch  := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 48) THEN
	             l_opt2_ws_amt_switch  := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 66) THEN
	             l_opt3_ws_amt_switch  := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 84) THEN
	             l_opt4_ws_amt_switch  := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 151) THEN
	             l_perf_switch         := '2';
		   ELSIF(l_cust_row.inf_Seq_Num = 3) THEN
	             l_rank_switch         := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 200) THEN
	             l_cpi_attribute1_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 201) THEN
	             l_cpi_attribute2_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 202) THEN
	             l_cpi_attribute3_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 203) THEN
	             l_cpi_attribute4_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 204) THEN
	             l_cpi_attribute5_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 205) THEN
	             l_cpi_attribute6_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 206) THEN
	             l_cpi_attribute7_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 207) THEN
	             l_cpi_attribute8_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 208) THEN
	             l_cpi_attribute9_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 209) THEN
	             l_cpi_attribute10_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 210) THEN
	             l_cpi_attribute11_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 211) THEN
	             l_cpi_attribute12_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 212) THEN
	             l_cpi_attribute13_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 213) THEN
	             l_cpi_attribute14_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 214) THEN
	             l_cpi_attribute15_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 215) THEN
	             l_cpi_attribute16_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 216) THEN
	             l_cpi_attribute17_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 217) THEN
	             l_cpi_attribute18_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 218) THEN
	             l_cpi_attribute19_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 219) THEN
	             l_cpi_attribute20_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 220) THEN
	             l_cpi_attribute21_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 221) THEN
	             l_cpi_attribute22_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 222) THEN
	             l_cpi_attribute23_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 223) THEN
	             l_cpi_attribute24_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 224) THEN
	             l_cpi_attribute25_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 225) THEN
	             l_cpi_attribute26_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 226) THEN
	             l_cpi_attribute27_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 227) THEN
	             l_cpi_attribute28_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 228) THEN
	             l_cpi_attribute29_switch  := '2';
	       ELSIF(l_cust_row.inf_Seq_Num = 229) THEN
	             l_cpi_attribute30_switch  := '2';
           ELSIF(l_cust_row.inf_Seq_Num in (126,152,191,192) ) THEN
                 l_promotion_switch        := '2';
           ELSIF(l_cust_row.inf_Seq_Num in (8,10,11,19,20,21) ) THEN
		     l_pl_other_rates_switch   := '2';
	       ELSIF(l_cust_row.inf_Seq_Num in (26,28,29,37,38,39) ) THEN
		     l_opt1_other_rates_switch := '2';
	       ELSIF(l_cust_row.inf_Seq_Num in (44,46,47,55,56,57) ) THEN
		     l_opt2_other_rates_switch   := '2';
	       ELSIF(l_cust_row.inf_Seq_Num in (62,64,65,73,74,75) ) THEN
		     l_opt3_other_rates_switch   := '2';
	       ELSIF(l_cust_row.inf_Seq_Num in (80,82,83,91,92,931) ) THEN
		      l_opt4_other_rates_switch   := '2';
           END IF;


           insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_cust_row.inf_Seq_Num
                                ,p_dis_seq          => l_cust_row.dis_Seq_Num * 10
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);

     End Loop;
End if;

l_num := 1;
-- Plan Group Cols
For l_row In group_pl_key
Loop
           insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);

  l_num := l_num + 1;
End Loop;

l_num := 1;
-- Option1  Group Cols
For l_row In group_opt1_key
Loop
           insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt );

  l_num := l_num + 1;
End Loop;
-- Option2  Group Cols
For l_row In group_opt2_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);

l_num := l_num + 1;
End Loop;
-- Option3  Group Cols
l_num := 1;
For l_row In group_opt3_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);

l_num := l_num + 1;
End Loop;
l_num := 1;
-- Option4  Group Cols
For l_row In group_opt4_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
l_num := l_num + 1;

End Loop;


l_num := 1;
-- Rank Group Cols
For l_row In group_rank_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
l_num := l_num + 1;

End Loop;

l_num := 1;
-- Group Job Cols
For l_row In group_job_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
l_num := l_num + 1;
End Loop;

l_num := 1;
-- Group Position Cols
For l_row In group_position_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
l_num := l_num + 1;
End Loop;

l_num := 1;
-- Grade Group Cols
For l_row In group_grade_key
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num + l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);
l_num := l_num + 1;
End Loop;

l_num := 10;

For l_row In add_cols
Loop
   	    insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt);

l_num := l_num + 10;

END Loop;

-- Don't distrub Cols
For l_row In do_not_disturb
Loop
            insert_cwb_layout_cols_row( p_application_id    => 800
                                ,p_base_layout_code => p_base_layout_code
                                ,p_act_layout_code  => p_act_layout_code
                                ,p_inf_seq          => l_row.inf_Seq_Num
                                ,p_dis_seq          => l_row.dis_Seq_Num
                                ,p_group_pl_id      => p_group_pl_id
                                ,p_lf_evt_ocrd_dt   => p_lf_evt_ocrd_dt );


End Loop;

       p_download_switch := '2' ||
                            l_pl_ws_amt_switch||
                            l_opt1_ws_amt_switch||
                            l_opt2_ws_amt_switch||
                            l_opt3_ws_amt_switch||
                            l_opt4_ws_amt_switch||
                            l_perf_switch||
                            l_rank_switch||
                            l_cpi_attribute1_switch||
                            l_cpi_attribute2_switch||
                            l_cpi_attribute3_switch||
                            l_cpi_attribute4_switch||
                            l_cpi_attribute5_switch||
                            l_cpi_attribute6_switch||
                            l_cpi_attribute7_switch||
                            l_cpi_attribute8_switch||
                            l_cpi_attribute9_switch||
                            l_cpi_attribute10_switch||
                            l_cpi_attribute11_switch||
                            l_cpi_attribute12_switch||
                            l_cpi_attribute13_switch||
                            l_cpi_attribute14_switch||
                            l_cpi_attribute15_switch||
                            l_cpi_attribute16_switch||
                            l_cpi_attribute17_switch||
                            l_cpi_attribute18_switch||
                            l_cpi_attribute19_switch||
                            l_cpi_attribute20_switch||
                            l_cpi_attribute21_switch||
                            l_cpi_attribute22_switch||
                            l_cpi_attribute23_switch||
                            l_cpi_attribute24_switch||
                            l_cpi_attribute25_switch||
                            l_cpi_attribute26_switch||
                            l_cpi_attribute27_switch||
                            l_cpi_attribute28_switch||
                            l_cpi_attribute29_switch||
                            l_cpi_attribute30_switch||
                            l_promotion_switch||
                            l_pl_other_rates_switch||
                            l_opt1_other_rates_switch||
                            l_opt2_other_rates_switch||
                            l_opt3_other_rates_switch||
                            l_opt4_other_rates_switch;

         p_download_switch := REPLACE(REPLACE(p_download_switch,'1','0'),'2','1');
         p_download_switch := nvl(lpad(int2hex(bin2int(substr(p_download_switch,1,28))),7,0)||
                              int2hex(bin2int(rpad(substr(p_download_switch,29),28,0))),'0000000');
If g_debug then
 hr_utility.set_location('Leaving '||l_proc,10);
END IF;
Exception
   When others then
      Null;
End update_cwb_custom_layout;

--
------------------- upsert_webadi_download_records ------------------------
--

Procedure upsert_webadi_download_records(p_session_id      IN Varchar2,
                                         p_download_type   IN Varchar2,
                                         p_param1          IN Varchar2 default null,
                                         p_param2          IN Varchar2 default null,
                                         p_param3          IN Varchar2 default null,
                                         p_param4          IN Varchar2 default null,
                                         p_param5          IN Varchar2 default null,
                                         p_param6          IN Varchar2 default null,
                                         p_param7          IN Varchar2 default null,
                                         p_param8          IN Varchar2 default null,
                                         p_param9          IN Varchar2 default null,
                                         p_param10         IN Varchar2 default null)
Is
begin
--
--
-- Store the time of download.
--
icx_sec.putSessionAttributeValue(p_session_id => p_session_id,
                                 p_name       => p_download_type||'_TIME',
                                 p_value      => to_char(sysdate,'YYYYMMDDHH24MISS')
                                 );
--
-- Store the parameter.
--
icx_sec.putSessionAttributeValue(p_session_id => p_session_id,
                                 p_name       => p_download_type,
                                 p_value      => p_param1
                                 );

--
--
End upsert_webadi_download_records;
--
--

--
--------------------------validate_grade_range----------------------
--
FUNCTION validate_grade_range(
    P_PL_PERSON_RATE_ID             IN     VARCHAR2
   ,P_P_OPT1_PERSON_RATE_ID         IN     VARCHAR2
   ,P_P_OPT2_PERSON_RATE_ID         IN     VARCHAR2
   ,P_P_OPT3_PERSON_RATE_ID         IN     VARCHAR2
   ,P_P_OPT4_PERSON_RATE_ID         IN     VARCHAR2
   ,P_PL_WS_VAL                     IN     VARCHAR2
   ,P_OPT1_WS_VAL                   IN     VARCHAR2
   ,P_OPT2_WS_VAL                   IN     VARCHAR2
   ,P_OPT3_WS_VAL                   IN     VARCHAR2
   ,P_OPT4_WS_VAL                   IN     VARCHAR2
   )
    RETURN VARCHAR2
IS

cursor c_plan_validation ( l_group_per_in_ler_id  number) is
select
nvl(lcl_pl.grade_range_validation,grp_pl.grade_range_validation) grade_range_validation
from
ben_cwb_pl_dsgn grp_pl
,ben_cwb_pl_dsgn lcl_pl
,ben_cwb_person_rates rates
where rates.group_per_in_ler_id = l_group_per_in_ler_id
and  rates.group_pl_id = grp_pl.pl_id
and  rates.lf_evt_ocrd_dt = grp_pl.lf_evt_ocrd_dt
and  grp_pl.oipl_id = -1
and  rates.pl_id = lcl_pl.pl_id
and  rates.lf_evt_ocrd_dt = lcl_pl.lf_evt_ocrd_dt
and  lcl_pl.oipl_id = -1
and rownum = 1;

cursor c_plan_salary ( l_group_per_in_ler_id  number,l_ws_val number) is
select
(per.base_salary*per.pay_annulization_factor/pl.pl_annulization_factor) base_salary,
decode(l_ws_val,'-0.0000000000000001',plRt.ws_val,l_ws_val) ws_val,
(per.grd_min_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_min,
(per.grd_max_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_max
from
ben_cwb_pl_dsgn pl
,ben_cwb_person_rates plRt
,ben_cwb_person_info per
where plRt.group_per_in_ler_id = l_group_per_in_ler_id
and   plRt.group_per_in_ler_id = per.group_per_in_ler_id
and   plRt.pl_id = pl.pl_id
and   plRt.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt
and   plRt.oipl_id = pl.oipl_id
and   pl.oipl_id = -1
and   pl.ws_sub_acty_typ_cd = 'ICM7';

cursor c_grade_range( l_group_per_in_ler_id  number) is
select
(per.base_salary*per.pay_annulization_factor/pl.pl_annulization_factor) base_salary,
(per.grd_min_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_min,
(per.grd_max_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_max
from
ben_cwb_pl_dsgn pl
,ben_cwb_person_rates plRt
,ben_cwb_person_info per
where plRt.group_per_in_ler_id = l_group_per_in_ler_id
and   plRt.group_per_in_ler_id = per.group_per_in_ler_id
and   plRt.pl_id = pl.pl_id
and   plRt.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt
and   plRt.oipl_id = pl.oipl_id
and   pl.oipl_id = -1;

cursor c_option_salary ( l_rate_id  number, l_ws_val number) is
select
(per.base_salary*per.pay_annulization_factor/pl.pl_annulization_factor) base_salary,
decode(l_ws_val,'-0.0000000000000001',optRt.ws_val,l_ws_val) ws_val,
(per.grd_min_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_min,
(per.grd_max_val*per.grade_annulization_factor/pl.pl_annulization_factor) grd_max,
per.group_per_in_ler_id
from
ben_cwb_pl_dsgn pl
,ben_cwb_person_rates optRt
,ben_cwb_person_info per
where optRt.person_rate_id = l_rate_id
and   optRt.group_per_in_ler_id = per.group_per_in_ler_id
and   optRt.pl_id = pl.pl_id
and   optRt.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt
and   optRt.oipl_id = pl.oipl_id
and   pl.oipl_id <> -1
and   pl.ws_sub_acty_typ_cd in ('ICM7','ICM11');

l_proc   varchar2(72) := g_package||'validate_grade_range';
l_pl_person_rate_id    Number := null;
l_opt1_person_rate_id  Number := null;
l_opt2_person_rate_id  Number := null;
l_opt3_person_rate_id  Number := null;
l_opt4_person_rate_id  Number := null;
l_group_per_in_ler_id  BEN_CWB_PERSON_RATES.GROUP_PER_IN_LER_ID%Type;
l_pl_ws_val            Number := 0;
l_opt1_ws_val          Number := 0;
l_opt2_ws_val          Number := 0;
l_opt3_ws_val          Number := 0;
l_opt4_ws_val          Number := 0;
l_new_salary           Number := null;
l_base_salary          Number := null;
l_grd_min              Number := null;
l_grd_max              Number := null;
l_return_msg           varchar2(500) := null;

BEGIN
  If g_debug then
    hr_utility.set_location('Entering '||l_proc,10);
  End if;
  IF  (P_PL_PERSON_RATE_ID  IS  NULL
     AND  P_P_OPT1_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT2_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT3_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT4_PERSON_RATE_ID IS  NULL) THEN

     If g_debug then
        hr_utility.set_location('No rates found '||l_proc,11);
     End if;
  END IF;
  IF (P_PL_PERSON_RATE_ID IS NOT NULL) THEN
   l_PL_PERSON_RATE_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_PL_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_PL_PERSON_RATE_ID   :'||l_PL_PERSON_RATE_ID,20);
   End if;
 END IF;

  IF (P_P_OPT1_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT1_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT1_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT1_PERSON_RATE_ID :'||l_OPT1_PERSON_RATE_ID,30);
   End if;
  END IF;

  IF (P_P_OPT2_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT2_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT2_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT2_PERSON_RATE_ID :'||l_OPT2_PERSON_RATE_ID,40);
   End if;
  END IF;

  IF (P_P_OPT3_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT3_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT3_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT3_PERSON_RATE_ID :'||l_OPT3_PERSON_RATE_ID,50);
   End if;
  END IF;

  IF (P_P_OPT4_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT4_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT4_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT4_PERSON_RATE_ID :'||l_OPT4_PERSON_RATE_ID,60);
   End if;
  END IF;

  l_group_per_in_ler_id := get_group_per_in_ler_id(l_PL_PERSON_RATE_ID,
                                                  l_OPT1_PERSON_RATE_ID,
                                                  l_OPT2_PERSON_RATE_ID,
                                                  l_OPT3_PERSON_RATE_ID,
                                                  l_OPT4_PERSON_RATE_ID);
  hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,70);

  for l_plan_validation in c_plan_validation(l_group_per_in_ler_id) loop
     for l_grade_range in c_grade_range(l_group_per_in_ler_id) loop
        l_base_salary := l_grade_range.base_salary;
	l_grd_min := l_grade_range.grd_min;
	l_grd_max := l_grade_range.grd_max;
	l_new_salary := 0;
	if((l_grd_min is not null) and (l_grd_max is not null)) then
		for l_option_salary in c_option_salary(l_OPT1_PERSON_RATE_ID,P_OPT1_WS_VAL) loop
		    l_opt1_ws_val := l_option_salary.ws_val;
		end loop;
		for l_option_salary in c_option_salary(l_OPT2_PERSON_RATE_ID,P_OPT2_WS_VAL) loop
		    l_opt2_ws_val := l_option_salary.ws_val;
		end loop;
		for l_option_salary in c_option_salary(l_OPT3_PERSON_RATE_ID,P_OPT3_WS_VAL) loop
		    l_opt3_ws_val := l_option_salary.ws_val;
		end loop;
		for l_option_salary in c_option_salary(l_OPT4_PERSON_RATE_ID,P_OPT4_WS_VAL) loop
		    l_opt4_ws_val := l_option_salary.ws_val;
		end loop;
		l_new_salary := l_base_salary + l_opt1_ws_val + l_opt2_ws_val + l_opt3_ws_val + l_opt4_ws_val;
		If g_debug then
		    hr_utility.set_location('l_new_salary :'||l_new_salary,80);
		    hr_utility.set_location('l_grd_min :'||l_grd_min,80);
		    hr_utility.set_location('l_grd_max :'||l_grd_max,80);
		End if;
		if((l_new_salary < l_grd_min) or (l_new_salary > l_grd_max) )then
		   If g_debug then
		    hr_utility.set_location('Leaving'||l_proc,90);
		   End if;
			-- l_return_msg := fnd_message.get_string('BEN','');
		   l_return_msg := l_plan_validation.grade_range_validation;
		   return l_return_msg;
	        end if;

		for l_plan_salary in c_plan_salary(l_group_per_in_ler_id,P_PL_WS_VAL) loop
		    l_new_salary := l_base_salary + l_plan_salary.ws_val;
		    if((l_new_salary < l_grd_min) or (l_new_salary > l_grd_max) )then
			If g_debug then
			   hr_utility.set_location('Leaving'||l_proc,100);
			End if;
			-- l_return_msg := fnd_message.get_string('BEN','');
			l_return_msg := l_plan_validation.grade_range_validation;
			return l_return_msg;
		    end if;
		end loop;
	end if;
     end loop;
  end loop;
  If g_debug then
    hr_utility.set_location('Leaving'||l_proc,110);
  End if;
  return null;

END;

--
--------------------------- get_group_per_in_ler_id -----------------------------
--

FUNCTION get_group_per_in_ler_id (P_PERSON_RATE_ID      IN    NUMBER Default Null
                                ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
                                Return Number
IS
Cursor csr_group_per_in_ler_id (l_person_rate_id IN Number)
IS
Select group_per_in_ler_id
from   ben_cwb_person_rates
where  person_rate_id = l_person_rate_id;

l_proc   		Varchar2(72) := g_package||'get_group_per_in_ler_id';
l_rate_id 		Number;
l_group_per_in_ler_id 	Number;


BEGIN

hr_utility.set_location('Entering   :'||l_proc,10);

If P_PERSON_RATE_ID IS NOT NULL then
   l_rate_id := P_PERSON_RATE_ID;
Elsif P_OPT1_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT1_PERSON_RATE_ID;
Elsif P_OPT2_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT2_PERSON_RATE_ID;
Elsif P_OPT3_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT3_PERSON_RATE_ID;
Elsif P_OPT4_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT4_PERSON_RATE_ID;
End if;

hr_utility.set_location('l_rate_id   :'||l_rate_id,20);

Open csr_group_per_in_ler_id(l_rate_id);
Fetch csr_group_per_in_ler_id into l_group_per_in_ler_id;
Close csr_group_per_in_ler_id;

hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,40);
hr_utility.set_location('Leaving   :'||l_proc,100);

return l_group_per_in_ler_id;

End get_group_per_in_ler_id;

--
---------------Utility functions for number conversions-------------
--
FUNCTION bin2int (bin VARCHAR2)
  RETURN PLS_INTEGER IS
  len PLS_INTEGER := LENGTH(bin);
  BEGIN
    IF NVL(len,1) = 1 THEN
      RETURN bin;
    ELSE RETURN
      2 * bin2int(SUBSTR(bin,1,len-1)) + SUBSTR(bin,-1);
    END IF;
END bin2int;

FUNCTION int2bin(int PLS_INTEGER)
  RETURN VARCHAR2 IS
  BEGIN
  hr_utility.set_location('int2bin:'||int, 300);
  IF int > 0 THEN
    RETURN int2bin(TRUNC(int/2))||
      SUBSTR('01',MOD(int,2)+1,1);
  ELSE
    RETURN NULL;
  END IF;
END int2bin;

FUNCTION hex2int(hex VARCHAR2)
  RETURN PLS_INTEGER IS
  len PLS_INTEGER := LENGTH(hex);
  BEGIN
    hr_utility.set_location('hex2int:'||hex, 300);
    IF NVL(len,1) = 1 THEN
      RETURN INSTR('0123456789ABCDEF',hex) - 1;
    ELSE
      hr_utility.set_location('hex2int length:'||len, 300);
      RETURN 16 * hex2int(SUBSTR(hex,1,len-1)) +
        INSTR('0123456789ABCDEF',SUBSTR(hex,-1)) - 1;
    END IF;
END hex2int;

FUNCTION int2hex(n PLS_INTEGER)
  RETURN VARCHAR2 IS
  BEGIN
  IF n > 0 THEN
    RETURN int2hex(TRUNC(n/16))||
      SUBSTR('0123456789ABCDEF',MOD(n,16)+1,1);
  ELSE
    RETURN NULL;
  END IF;
END int2hex;

FUNCTION int2base(int PLS_INTEGER,base PLS_INTEGER)
  RETURN VARCHAR2 IS
  BEGIN
    IF int > 0 THEN
      RETURN int2base(TRUNC(int/base),base)||
	   SUBSTR('0123456789ABCDEF',MOD(int,base)+1,1);
    ELSE
      RETURN NULL;
  END IF;
END int2base;

FUNCTION base2int(num VARCHAR2,base PLS_INTEGER)
  RETURN PLS_INTEGER IS
  len PLS_INTEGER := LENGTH(num);
  BEGIN
    IF NVL(len,1) = 1 THEN
      RETURN INSTR('0123456789ABCDEF',num) - 1;
    ELSE
      RETURN base * base2int(SUBSTR(num,1,len-1),base) +
        INSTR('0123456789ABCDEF',SUBSTR(num,-1)) - 1;
  END IF;
END base2int;
--
--
END ben_cwb_webadi_utils;


/
