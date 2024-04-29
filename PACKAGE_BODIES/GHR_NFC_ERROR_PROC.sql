--------------------------------------------------------
--  DDL for Package Body GHR_NFC_ERROR_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NFC_ERROR_PROC" AS
/* $Header: ghrnfcerrext.pkb 120.13 2006/02/06 06:42:16 sumarimu noship $ */

--g_proc_name  Varchar2(200) :='GHR_NFC_ERROR_PROC';

--=================================================================
--upd_Rslt_Dtl
--================================================================
procedure upd_Rslt_Dtl
          (p_val_tab     in out NOCOPY ben_ext_rslt_dtl%rowtype
          ,p_dat_tab     in  ben_ext_rslt_dtl%rowtype
          ) is

l_proc_name     Varchar2(150) := g_proc_name ||'.upd_Rslt_Dtl';
BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
---check for null value and replaces with the original value.



  IF p_val_tab.val_02 IS NULL THEN
   p_val_tab.val_02 :=p_dat_tab.val_02;
  END IF;
  IF p_val_tab.val_03 IS NULL THEN
   p_val_tab.val_03 :=p_dat_tab.val_03;
  END IF;
  IF p_val_tab.val_04 IS NULL THEN
   p_val_tab.val_04 :=p_dat_tab.val_04;
  END IF;
  IF p_val_tab.val_05 IS NULL THEN
   p_val_tab.val_05 :=p_dat_tab.val_05;
  END IF;
  IF p_val_tab.val_06 IS NULL THEN
   p_val_tab.val_06 :=p_dat_tab.val_06;
  END IF;
  IF p_val_tab.val_07 IS NULL THEN
   p_val_tab.val_07 :=p_dat_tab.val_07;
  END IF;
  IF p_val_tab.val_08 IS NULL THEN
   p_val_tab.val_08 :=p_dat_tab.val_08;
  END IF;
  IF p_val_tab.val_09 IS NULL THEN
   p_val_tab.val_09 :=p_dat_tab.val_09;
  END IF;
  IF p_val_tab.val_10 IS NULL THEN
   p_val_tab.val_10 :=p_dat_tab.val_10;
  END IF;
  IF p_val_tab.val_11 IS NULL THEN
   p_val_tab.val_11 :=p_dat_tab.val_11;
  END IF;
  IF p_val_tab.val_12 IS NULL THEN
   p_val_tab.val_12 :=p_dat_tab.val_12;
  END IF;
  IF p_val_tab.val_13 IS NULL THEN
   p_val_tab.val_13 :=p_dat_tab.val_13;
  END IF;
  IF p_val_tab.val_14 IS NULL THEN
   p_val_tab.val_14 :=p_dat_tab.val_14;
  END IF;
  IF p_val_tab.val_15 IS NULL THEN
   p_val_tab.val_15 :=p_dat_tab.val_15;
  END IF;
  IF p_val_tab.val_16 IS NULL THEN
   p_val_tab.val_16 :=p_dat_tab.val_16;
  END IF;
  IF p_val_tab.val_17 IS NULL THEN
   p_val_tab.val_17 :=p_dat_tab.val_17;
  END IF;
  IF p_val_tab.val_18 IS NULL THEN
   p_val_tab.val_18 :=p_dat_tab.val_18;
  END IF;
  IF p_val_tab.val_19 IS NULL THEN
   p_val_tab.val_19 :=p_dat_tab.val_19;
  END IF;
  IF p_val_tab.val_20 IS NULL THEN
   p_val_tab.val_20 :=p_dat_tab.val_20;
  END IF;
  IF p_val_tab.val_21 IS NULL THEN
   p_val_tab.val_21 :=p_dat_tab.val_21;
  END IF;
  IF p_val_tab.val_22 IS NULL THEN
   p_val_tab.val_22 :=p_dat_tab.val_22;
  END IF;
  IF p_val_tab.val_23 IS NULL THEN
   p_val_tab.val_23 :=p_dat_tab.val_23;
  END IF;
  IF p_val_tab.val_24 IS NULL THEN
   p_val_tab.val_24 :=p_dat_tab.val_24;
  END IF;
  IF p_val_tab.val_25 IS NULL THEN
   p_val_tab.val_25 :=p_dat_tab.val_25;
  END IF;
  IF p_val_tab.val_26 IS NULL THEN
   p_val_tab.val_26 :=p_dat_tab.val_26;
  END IF;
  IF p_val_tab.val_27 IS NULL THEN
   p_val_tab.val_27 :=p_dat_tab.val_27;
  END IF;
  IF p_val_tab.val_28 IS NULL THEN
   p_val_tab.val_28 :=p_dat_tab.val_28;
  END IF;
  IF p_val_tab.val_29 IS NULL THEN
   p_val_tab.val_29 :=p_dat_tab.val_29;
  END IF;
  IF p_val_tab.val_30 IS NULL THEN
   p_val_tab.val_30 :=p_dat_tab.val_30;
  END IF;
  IF p_val_tab.val_31 IS NULL THEN
   p_val_tab.val_31 :=p_dat_tab.val_31;
  END IF;
  IF p_val_tab.val_32 IS NULL THEN
   p_val_tab.val_32 :=p_dat_tab.val_32;
  END IF;
  IF p_val_tab.val_33 IS NULL THEN
   p_val_tab.val_33 :=p_dat_tab.val_33;
  END IF;
  IF p_val_tab.val_34 IS NULL THEN
   p_val_tab.val_34 :=p_dat_tab.val_34;
  END IF;
  IF p_val_tab.val_35 IS NULL THEN
   p_val_tab.val_35 :=p_dat_tab.val_35;
  END IF;
  IF p_val_tab.val_36 IS NULL THEN
   p_val_tab.val_36 :=p_dat_tab.val_36;
  END IF;
  IF p_val_tab.val_37 IS NULL THEN
   p_val_tab.val_37 :=p_dat_tab.val_37;
  END IF;
  IF p_val_tab.val_38 IS NULL THEN
   p_val_tab.val_38 :=p_dat_tab.val_38;
  END IF;
  IF p_val_tab.val_39 IS NULL THEN
   p_val_tab.val_39 :=p_dat_tab.val_39;
  END IF;

  IF p_val_tab.val_40 IS NULL THEN
   p_val_tab.val_40 :=p_dat_tab.val_40;
  END IF;
  IF p_val_tab.val_41 IS NULL THEN
   p_val_tab.val_41 :=p_dat_tab.val_41;
  END IF;
  IF p_val_tab.val_42 IS NULL THEN
   p_val_tab.val_42 :=p_dat_tab.val_42;
  END IF;
  IF p_val_tab.val_43 IS NULL THEN
   p_val_tab.val_43 :=p_dat_tab.val_43;
  END IF;
  IF p_val_tab.val_44 IS NULL THEN
   p_val_tab.val_44 :=p_dat_tab.val_44;
  END IF;
  IF p_val_tab.val_45 IS NULL THEN
   p_val_tab.val_45 :=p_dat_tab.val_45;
  END IF;
  IF p_val_tab.val_46 IS NULL THEN
   p_val_tab.val_46 :=p_dat_tab.val_46;
  END IF;
  IF p_val_tab.val_47 IS NULL THEN
   p_val_tab.val_47 :=p_dat_tab.val_47;
  END IF;
  IF p_val_tab.val_48 IS NULL THEN
   p_val_tab.val_48 :=p_dat_tab.val_48;
  END IF;
  IF p_val_tab.val_49 IS NULL THEN
   p_val_tab.val_49 :=p_dat_tab.val_49;
  END IF;

  IF p_val_tab.val_50 IS NULL THEN
   p_val_tab.val_50 :=p_dat_tab.val_50;
  END IF;
  IF p_val_tab.val_51 IS NULL THEN
   p_val_tab.val_51 :=p_dat_tab.val_51;
  END IF;
  IF p_val_tab.val_52 IS NULL THEN
   p_val_tab.val_52 :=p_dat_tab.val_52;
  END IF;
  IF p_val_tab.val_53 IS NULL THEN
   p_val_tab.val_53 :=p_dat_tab.val_53;
  END IF;
  IF p_val_tab.val_54 IS NULL THEN
   p_val_tab.val_54 :=p_dat_tab.val_54;
  END IF;
  IF p_val_tab.val_55 IS NULL THEN
   p_val_tab.val_55 :=p_dat_tab.val_55;
  END IF;
  IF p_val_tab.val_56 IS NULL THEN
   p_val_tab.val_56 :=p_dat_tab.val_56;
  END IF;
  IF p_val_tab.val_57 IS NULL THEN
   p_val_tab.val_57 :=p_dat_tab.val_57;
  END IF;
  IF p_val_tab.val_58 IS NULL THEN
   p_val_tab.val_58 :=p_dat_tab.val_58;
  END IF;
  IF p_val_tab.val_59 IS NULL THEN
   p_val_tab.val_59 :=p_dat_tab.val_59;
  END IF;

  IF p_val_tab.val_60 IS NULL THEN
   p_val_tab.val_60 :=p_dat_tab.val_60;
  END IF;
  IF p_val_tab.val_61 IS NULL THEN
   p_val_tab.val_61 :=p_dat_tab.val_61;
  END IF;
  IF p_val_tab.val_62 IS NULL THEN
   p_val_tab.val_62 :=p_dat_tab.val_62;
  END IF;
  IF p_val_tab.val_63 IS NULL THEN
   p_val_tab.val_63 :=p_dat_tab.val_63;
  END IF;
  IF p_val_tab.val_64 IS NULL THEN
   p_val_tab.val_64 :=p_dat_tab.val_64;
  END IF;
  IF p_val_tab.val_65 IS NULL THEN
   p_val_tab.val_65 :=p_dat_tab.val_65;
  END IF;
  IF p_val_tab.val_66 IS NULL THEN
   p_val_tab.val_66 :=p_dat_tab.val_66;
  END IF;
  IF p_val_tab.val_67 IS NULL THEN
   p_val_tab.val_67 :=p_dat_tab.val_67;
  END IF;
  IF p_val_tab.val_68 IS NULL THEN
   p_val_tab.val_68 :=p_dat_tab.val_68;
  END IF;
  IF p_val_tab.val_69 IS NULL THEN
   p_val_tab.val_69 :=p_dat_tab.val_69;
  END IF;

  IF p_val_tab.val_70 IS NULL THEN
   p_val_tab.val_70 :=p_dat_tab.val_70;
  END IF;
  IF p_val_tab.val_71 IS NULL THEN
   p_val_tab.val_71 :=p_dat_tab.val_71;
  END IF;
  IF p_val_tab.val_72 IS NULL THEN
   p_val_tab.val_72 :=p_dat_tab.val_72;
  END IF;
  IF p_val_tab.val_73 IS NULL THEN
   p_val_tab.val_73 :=p_dat_tab.val_73;
  END IF;
  IF p_val_tab.val_74 IS NULL THEN
   p_val_tab.val_74 :=p_dat_tab.val_74;
  END IF;
  IF p_val_tab.val_75 IS NULL THEN
   p_val_tab.val_75 :=p_dat_tab.val_75;
  END IF;
  IF p_val_tab.val_76 IS NULL THEN
   p_val_tab.val_76 :=p_dat_tab.val_76;
  END IF;
  IF p_val_tab.val_77 IS NULL THEN
   p_val_tab.val_77 :=p_dat_tab.val_77;
  END IF;
  IF p_val_tab.val_78 IS NULL THEN
   p_val_tab.val_78 :=p_dat_tab.val_78;
  END IF;
  IF p_val_tab.val_79 IS NULL THEN
   p_val_tab.val_79 :=p_dat_tab.val_79;
  END IF;

  IF p_val_tab.val_80 IS NULL THEN
   p_val_tab.val_80 :=p_dat_tab.val_80;
  END IF;
  IF p_val_tab.val_81 IS NULL THEN
   p_val_tab.val_81 :=p_dat_tab.val_81;
  END IF;
  IF p_val_tab.val_82 IS NULL THEN
   p_val_tab.val_82 :=p_dat_tab.val_82;
  END IF;
  IF p_val_tab.val_83 IS NULL THEN
   p_val_tab.val_83 :=p_dat_tab.val_83;
  END IF;
  IF p_val_tab.val_84 IS NULL THEN
   p_val_tab.val_84 :=p_dat_tab.val_84;
  END IF;
  IF p_val_tab.val_85 IS NULL THEN
   p_val_tab.val_85 :=p_dat_tab.val_85;
  END IF;
  IF p_val_tab.val_86 IS NULL THEN
   p_val_tab.val_86 :=p_dat_tab.val_86;
  END IF;
  IF p_val_tab.val_87 IS NULL THEN
   p_val_tab.val_87 :=p_dat_tab.val_87;
  END IF;
  IF p_val_tab.val_88 IS NULL THEN
   p_val_tab.val_88 :=p_dat_tab.val_88;
  END IF;
  IF p_val_tab.val_89 IS NULL THEN
   p_val_tab.val_89 :=p_dat_tab.val_89;
  END IF;

  IF p_val_tab.val_90 IS NULL THEN
   p_val_tab.val_90 :=p_dat_tab.val_90;
  END IF;
  IF p_val_tab.val_91 IS NULL THEN
   p_val_tab.val_91 :=p_dat_tab.val_91;
  END IF;
  IF p_val_tab.val_92 IS NULL THEN
   p_val_tab.val_92 :=p_dat_tab.val_92;
  END IF;
  IF p_val_tab.val_93 IS NULL THEN
   p_val_tab.val_93 :=p_dat_tab.val_93;
  END IF;
  IF p_val_tab.val_94 IS NULL THEN
   p_val_tab.val_94 :=p_dat_tab.val_94;
  END IF;
  IF p_val_tab.val_95 IS NULL THEN
   p_val_tab.val_95 :=p_dat_tab.val_95;
  END IF;
  IF p_val_tab.val_96 IS NULL THEN
   p_val_tab.val_96 :=p_dat_tab.val_96;
  END IF;
  IF p_val_tab.val_97 IS NULL THEN
   p_val_tab.val_97 :=p_dat_tab.val_97;
  END IF;
  IF p_val_tab.val_98 IS NULL THEN
   p_val_tab.val_98 :=p_dat_tab.val_98;
  END IF;
  IF p_val_tab.val_99 IS NULL THEN
   p_val_tab.val_99 :=p_dat_tab.val_99;
  END IF;

  IF p_val_tab.val_100 IS NULL THEN
   p_val_tab.val_100 :=p_dat_tab.val_100;
  END IF;
  IF p_val_tab.val_101 IS NULL THEN
   p_val_tab.val_101 :=p_dat_tab.val_101;
  END IF;
  IF p_val_tab.val_102 IS NULL THEN
   p_val_tab.val_102 :=p_dat_tab.val_102;
  END IF;
  IF p_val_tab.val_103 IS NULL THEN
   p_val_tab.val_103 :=p_dat_tab.val_103;
  END IF;
  IF p_val_tab.val_104 IS NULL THEN
   p_val_tab.val_104 :=p_dat_tab.val_104;
  END IF;
  IF p_val_tab.val_105 IS NULL THEN
   p_val_tab.val_105 :=p_dat_tab.val_105;
  END IF;
  IF p_val_tab.val_106 IS NULL THEN
   p_val_tab.val_106 :=p_dat_tab.val_106;
  END IF;
  IF p_val_tab.val_107 IS NULL THEN
   p_val_tab.val_107 :=p_dat_tab.val_107;
  END IF;
  IF p_val_tab.val_108 IS NULL THEN
   p_val_tab.val_108 :=p_dat_tab.val_108;
  END IF;
  IF p_val_tab.val_109 IS NULL THEN
   p_val_tab.val_109 :=p_dat_tab.val_109;
  END IF;

  IF p_val_tab.val_110 IS NULL THEN
   p_val_tab.val_110 :=p_dat_tab.val_110;
  END IF;
  IF p_val_tab.val_111 IS NULL THEN
   p_val_tab.val_111 :=p_dat_tab.val_111;
  END IF;
  IF p_val_tab.val_112 IS NULL THEN
   p_val_tab.val_112 :=p_dat_tab.val_112;
  END IF;
  IF p_val_tab.val_113 IS NULL THEN
   p_val_tab.val_113 :=p_dat_tab.val_113;
  END IF;
  IF p_val_tab.val_114 IS NULL THEN
   p_val_tab.val_114 :=p_dat_tab.val_114;
  END IF;
  IF p_val_tab.val_115 IS NULL THEN
   p_val_tab.val_115 :=p_dat_tab.val_115;
  END IF;
  IF p_val_tab.val_116 IS NULL THEN
   p_val_tab.val_116 :=p_dat_tab.val_116;
  END IF;
  IF p_val_tab.val_117 IS NULL THEN
   p_val_tab.val_117 :=p_dat_tab.val_117;
  END IF;
  IF p_val_tab.val_118 IS NULL THEN
   p_val_tab.val_118 :=p_dat_tab.val_118;
  END IF;
  IF p_val_tab.val_119 IS NULL THEN
   p_val_tab.val_119 :=p_dat_tab.val_119;
  END IF;

  IF p_val_tab.val_120 IS NULL THEN
   p_val_tab.val_120 :=p_dat_tab.val_120;
  END IF;
  IF p_val_tab.val_121 IS NULL THEN
   p_val_tab.val_121 :=p_dat_tab.val_121;
  END IF;
  IF p_val_tab.val_122 IS NULL THEN
   p_val_tab.val_122 :=p_dat_tab.val_122;
  END IF;
  IF p_val_tab.val_123 IS NULL THEN
   p_val_tab.val_123 :=p_dat_tab.val_123;
  END IF;
  IF p_val_tab.val_124 IS NULL THEN
   p_val_tab.val_124 :=p_dat_tab.val_124;
  END IF;
  IF p_val_tab.val_125 IS NULL THEN
   p_val_tab.val_125 :=p_dat_tab.val_125;
  END IF;
  IF p_val_tab.val_126 IS NULL THEN
   p_val_tab.val_126 :=p_dat_tab.val_126;
  END IF;
  IF p_val_tab.val_127 IS NULL THEN
   p_val_tab.val_127 :=p_dat_tab.val_127;
  END IF;
  IF p_val_tab.val_128 IS NULL THEN
   p_val_tab.val_128 :=p_dat_tab.val_128;
  END IF;
  IF p_val_tab.val_129 IS NULL THEN
   p_val_tab.val_129 :=p_dat_tab.val_129;
  END IF;

  IF p_val_tab.val_130 IS NULL THEN
   p_val_tab.val_130 :=p_dat_tab.val_130;
  END IF;
  IF p_val_tab.val_131 IS NULL THEN
   p_val_tab.val_131 :=p_dat_tab.val_131;
  END IF;
  IF p_val_tab.val_132 IS NULL THEN
   p_val_tab.val_132 :=p_dat_tab.val_132;
  END IF;
  IF p_val_tab.val_133 IS NULL THEN
   p_val_tab.val_133 :=p_dat_tab.val_133;
  END IF;
  IF p_val_tab.val_134 IS NULL THEN
   p_val_tab.val_134 :=p_dat_tab.val_134;
  END IF;
  IF p_val_tab.val_135 IS NULL THEN
   p_val_tab.val_135 :=p_dat_tab.val_135;
  END IF;
  IF p_val_tab.val_136 IS NULL THEN
   p_val_tab.val_136 :=p_dat_tab.val_136;
  END IF;
  IF p_val_tab.val_137 IS NULL THEN
   p_val_tab.val_137 :=p_dat_tab.val_137;
  END IF;
  IF p_val_tab.val_138 IS NULL THEN
   p_val_tab.val_138 :=p_dat_tab.val_138;
  END IF;
  IF p_val_tab.val_139 IS NULL THEN
   p_val_tab.val_139 :=p_dat_tab.val_139;
  END IF;

  IF p_val_tab.val_140 IS NULL THEN
   p_val_tab.val_140 :=p_dat_tab.val_140;
  END IF;
  IF p_val_tab.val_141 IS NULL THEN
   p_val_tab.val_141 :=p_dat_tab.val_141;
  END IF;
  IF p_val_tab.val_142 IS NULL THEN
   p_val_tab.val_142 :=p_dat_tab.val_142;
  END IF;
  IF p_val_tab.val_143 IS NULL THEN
   p_val_tab.val_143 :=p_dat_tab.val_143;
  END IF;
  IF p_val_tab.val_144 IS NULL THEN
   p_val_tab.val_144 :=p_dat_tab.val_144;
  END IF;
  IF p_val_tab.val_145 IS NULL THEN
   p_val_tab.val_145 :=p_dat_tab.val_145;
  END IF;
  IF p_val_tab.val_146 IS NULL THEN
   p_val_tab.val_146 :=p_dat_tab.val_146;
  END IF;
  IF p_val_tab.val_147 IS NULL THEN
   p_val_tab.val_147 :=p_dat_tab.val_147;
  END IF;
  IF p_val_tab.val_148 IS NULL THEN
   p_val_tab.val_148 :=p_dat_tab.val_148;
  END IF;
  IF p_val_tab.val_149 IS NULL THEN
   p_val_tab.val_149 :=p_dat_tab.val_149;
  END IF;
  IF p_val_tab.val_150 IS NULL THEN
   p_val_tab.val_150 :=p_dat_tab.val_150;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;
--=================================================================
--Ins_Rslt_Dtl
--================================================================
procedure Ins_Rslt_Dtl
          (p_val_tab     in out NOCOPY ben_ext_rslt_dtl%rowtype
          ,p_rslt_dtl_id out NOCOPY number
          ) is

  l_proc_name   varchar2(150) := g_proc_name||'Ins_Rslt_Dtl';
  l_dtl_rec_nc  ben_ext_rslt_dtl%rowtype;

begin -- ins_rslt_dtl
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
  -- nocopy changes
  --l_dtl_rec_nc := p_dtl_rec;
  -- Get the next sequence NUMBER to insert a record into the table
  select ben_ext_rslt_dtl_s.nextval into p_val_tab.ext_rslt_dtl_id from dual;
  insert into ben_ext_rslt_dtl
  (ext_rslt_dtl_id
  ,ext_rslt_id
  ,business_group_id
  ,ext_rcd_id
  ,person_id
  ,val_01
  ,val_02
  ,val_03
  ,val_04
  ,val_05
  ,val_06
  ,val_07
  ,val_08
  ,val_09
  ,val_10
  ,val_11
  ,val_12
  ,val_13
  ,val_14
  ,val_15
  ,val_16
  ,val_17
  ,val_19
  ,val_18
  ,val_20
  ,val_21
  ,val_22
  ,val_23
  ,val_24
  ,val_25
  ,val_26
  ,val_27
  ,val_28
  ,val_29
  ,val_30
  ,val_31
  ,val_32
  ,val_33
  ,val_34
  ,val_35
  ,val_36
  ,val_37
  ,val_38
  ,val_39
  ,val_40
  ,val_41
  ,val_42
  ,val_43
  ,val_44
  ,val_45
  ,val_46
  ,val_47
  ,val_48
  ,val_49
  ,val_50
  ,val_51
  ,val_52
  ,val_53
  ,val_54
  ,val_55
  ,val_56
  ,val_57
  ,val_58
  ,val_59
  ,val_60
  ,val_61
  ,val_62
  ,val_63
  ,val_64
  ,val_65
  ,val_66
  ,val_67
  ,val_68
  ,val_69
  ,val_70
  ,val_71
  ,val_72
  ,val_73
  ,val_74
  ,val_75
  ,val_76
  ,val_77
  ,val_78
  ,val_79
  ,val_80
  ,val_81
  ,val_82
  ,val_83
  ,val_84
  ,val_85
  ,val_86
  ,val_87
  ,val_88
  ,val_89
  ,val_90
  ,val_91
  ,val_92
  ,val_93
  ,val_94
  ,val_95
  ,val_96
  ,val_97
  ,val_98
  ,val_99
  ,val_100
  ,val_101
  ,val_102
  ,val_103
  ,val_104
  ,val_105
  ,val_106
  ,val_107
  ,val_108
  ,val_109
  ,val_110
  ,val_111
  ,val_112
  ,val_113
  ,val_114
  ,val_115
  ,val_116
  ,val_117
  ,val_118
  ,val_119
  ,val_120
  ,val_121
  ,val_122
  ,val_123
  ,val_124
  ,val_125
  ,val_126
  ,val_127
  ,val_128
  ,val_129
  ,val_130
  ,val_131
  ,val_132
  ,val_133
  ,val_134
  ,val_135
  ,val_136
  ,val_137
  ,val_138
  ,val_139
  ,val_140
  ,val_141
  ,val_142
  ,val_143
  ,val_144
  ,val_145
  ,val_146
  ,val_147
  ,val_148
  ,val_149
  ,val_150
  ,created_by
  ,creation_date
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,program_application_id
  ,program_id
  ,program_update_date
  ,request_id
  ,object_version_number
  ,prmy_sort_val
  ,scnd_sort_val
  ,thrd_sort_val
  ,trans_seq_num
  ,rcrd_seq_num
  )
  values
  (p_val_tab.ext_rslt_dtl_id
  ,p_val_tab.ext_rslt_id
  ,p_val_tab.business_group_id
  ,p_val_tab.ext_rcd_id
  ,p_val_tab.person_id
  ,p_val_tab.val_01
  ,p_val_tab.val_02
  ,p_val_tab.val_03
  ,p_val_tab.val_04
  ,p_val_tab.val_05
  ,p_val_tab.val_06
  ,p_val_tab.val_07
  ,p_val_tab.val_08
  ,p_val_tab.val_09
  ,p_val_tab.val_10
  ,p_val_tab.val_11
  ,p_val_tab.val_12
  ,p_val_tab.val_13
  ,p_val_tab.val_14
  ,p_val_tab.val_15
  ,p_val_tab.val_16
  ,p_val_tab.val_17
  ,p_val_tab.val_18
  ,p_val_tab.val_19
  ,p_val_tab.val_20
  ,p_val_tab.val_21
  ,p_val_tab.val_22
  ,p_val_tab.val_23
  ,p_val_tab.val_24
  ,p_val_tab.val_25
  ,p_val_tab.val_26
  ,p_val_tab.val_27
  ,p_val_tab.val_28
  ,p_val_tab.val_29
  ,p_val_tab.val_30
  ,p_val_tab.val_31
  ,p_val_tab.val_32
  ,p_val_tab.val_33
  ,p_val_tab.val_34
  ,p_val_tab.val_35
  ,p_val_tab.val_36
  ,p_val_tab.val_37
  ,p_val_tab.val_38
  ,p_val_tab.val_39
  ,p_val_tab.val_40
  ,p_val_tab.val_41
  ,p_val_tab.val_42
  ,p_val_tab.val_43
  ,p_val_tab.val_44
  ,p_val_tab.val_45
  ,p_val_tab.val_46
  ,p_val_tab.val_47
  ,p_val_tab.val_48
  ,p_val_tab.val_49
  ,p_val_tab.val_50
  ,p_val_tab.val_51
  ,p_val_tab.val_52
  ,p_val_tab.val_53
  ,p_val_tab.val_54
  ,p_val_tab.val_55
  ,p_val_tab.val_56
  ,p_val_tab.val_57
  ,p_val_tab.val_58
  ,p_val_tab.val_59
  ,p_val_tab.val_60
  ,p_val_tab.val_61
  ,p_val_tab.val_62
  ,p_val_tab.val_63
  ,p_val_tab.val_64
  ,p_val_tab.val_65
  ,p_val_tab.val_66
  ,p_val_tab.val_67
  ,p_val_tab.val_68
  ,p_val_tab.val_69
  ,p_val_tab.val_70
  ,p_val_tab.val_71
  ,p_val_tab.val_72
  ,p_val_tab.val_73
  ,p_val_tab.val_74
  ,p_val_tab.val_75
  ,p_val_tab.val_76
  ,p_val_tab.val_77
  ,p_val_tab.val_78
  ,p_val_tab.val_79
  ,p_val_tab.val_80
  ,p_val_tab.val_81
  ,p_val_tab.val_82
  ,p_val_tab.val_83
  ,p_val_tab.val_84
  ,p_val_tab.val_85
  ,p_val_tab.val_86
  ,p_val_tab.val_87
  ,p_val_tab.val_88
  ,p_val_tab.val_89
  ,p_val_tab.val_90
  ,p_val_tab.val_91
  ,p_val_tab.val_92
  ,p_val_tab.val_93
  ,p_val_tab.val_94
  ,p_val_tab.val_95
  ,p_val_tab.val_96
  ,p_val_tab.val_97
  ,p_val_tab.val_98
  ,p_val_tab.val_99
  ,p_val_tab.val_100
  ,p_val_tab.val_101
  ,p_val_tab.val_102
  ,p_val_tab.val_103
  ,p_val_tab.val_104
  ,p_val_tab.val_105
  ,p_val_tab.val_106
  ,p_val_tab.val_107
  ,p_val_tab.val_108
  ,p_val_tab.val_109
  ,p_val_tab.val_110
  ,p_val_tab.val_111
  ,p_val_tab.val_112
  ,p_val_tab.val_113
  ,p_val_tab.val_114
  ,p_val_tab.val_115
  ,p_val_tab.val_116
  ,p_val_tab.val_117
  ,p_val_tab.val_118
  ,p_val_tab.val_119
  ,p_val_tab.val_120
  ,p_val_tab.val_121
  ,p_val_tab.val_122
  ,p_val_tab.val_123
  ,p_val_tab.val_124
  ,p_val_tab.val_125
  ,p_val_tab.val_126
  ,p_val_tab.val_127
  ,p_val_tab.val_128
  ,p_val_tab.val_129
  ,p_val_tab.val_130
  ,p_val_tab.val_131
  ,p_val_tab.val_132
  ,p_val_tab.val_133
  ,p_val_tab.val_134
  ,p_val_tab.val_135
  ,p_val_tab.val_136
  ,p_val_tab.val_137
  ,p_val_tab.val_138
  ,p_val_tab.val_139
  ,p_val_tab.val_140
  ,p_val_tab.val_141
  ,p_val_tab.val_142
  ,p_val_tab.val_143
  ,p_val_tab.val_144
  ,p_val_tab.val_145
  ,p_val_tab.val_146
  ,p_val_tab.val_147
  ,p_val_tab.val_148
  ,p_val_tab.val_149
  ,p_val_tab.val_150
  ,p_val_tab.created_by
  ,p_val_tab.creation_date
  ,p_val_tab.last_update_date
  ,p_val_tab.last_updated_by
  ,p_val_tab.last_update_login
  ,p_val_tab.program_application_id
  ,p_val_tab.program_id
  ,p_val_tab.program_update_date
  ,p_val_tab.request_id
  ,p_val_tab.object_version_number
  ,p_val_tab.prmy_sort_val
  ,p_val_tab.scnd_sort_val
  ,p_val_tab.thrd_sort_val
  ,p_val_tab.trans_seq_num
  ,p_val_tab.rcrd_seq_num
  );
  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  return;

exception
  when Others then
    Hr_Utility.set_location('Leaving - Error :'||sqlerrm|| l_proc_name, 25);
    --p_dtl_rec := l_dtl_rec_nc;
    raise;
end Ins_Rslt_Dtl;
---============================================================================
--PROCEDURE chk_dual_action
---===========================================================================
PROCEDURE chk_dual_action (p_request_id  IN NUMBER
                          ,p_rslt_id     IN NUMBER
                          )
IS

CURSOR c_get_dual_action (cp_request_id  NUMBER
                         ,cp_rslt_id     NUMBER
                          )
IS
SELECT  COUNT (person_id) cnt
  FROM ben_ext_rslt_dtl berd
 WHERE berd.request_id =cp_request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND berd.val_29      ='352'
   AND berd.val_30      ='825'
   AND berd.val_03      ='063';

l_rslt_dtl     ben_ext_rslt_dtl%ROWTYPE;
l_count        NUMBER;
l_proc_name     Varchar2(150) := g_proc_name ||'.chk_dual_action';
BEGIN
 Hr_Utility.set_location('Entering :'||l_proc_name, 5);
 OPEN c_get_dual_action (p_request_id
                        ,p_rslt_id
                         );
 FETCH c_get_dual_action INTO l_count;
 CLOSE c_get_dual_action;
 Hr_Utility.set_location('l_count: '||l_count, 5);

 IF l_count > 0 THEN
  UPDATE ben_ext_rslt_dtl berd
     SET berd.val_30 = NULL
   WHERE berd.request_id =p_request_id
     AND berd.ext_rslt_id =p_rslt_id
     AND berd.val_29      ='352'
     AND berd.val_30      ='825'
     AND berd.val_03      ='063' ;
 END IF;
 Hr_Utility.set_location('Leaving :'||l_proc_name, 5);

END;

---============================================================================
--PROCEDURE chk_same_day_act
--This procedure checks for the original action and correction occured
--on the same day.
--When the original action is corrected, the report should have only one row
--with original action but having the corrected value.
--If the origibnal action is cancelled, then both the rows are not sent.
---===========================================================================
PROCEDURE chk_same_day_act_nfc (p_request_id  IN NUMBER
                           ,p_rslt_id     IN NUMBER
                           )
IS
CURSOR c_chk_dup_action (cp_request_id NUMBER
                         ,cp_rslt_id     NUMBER
                         )
IS
SELECT berd.*
  FROM  ben_ext_rslt_dtl berd
       ,ben_ext_rslt_dtl berd1
 WHERE berd.request_id  =cp_request_id
   AND berd.request_id  =berd1.request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND berd.ext_rslt_id =berd1.ext_rslt_id
   AND ( (berd.val_03   ='063'
   AND berd.val_03      =berd1.val_03
   AND  berd.val_30     =berd1.val_29
   AND berd.val_29      IN ('001','002')
   AND berd.val_150     =berd1.val_01)
    OR (berd.val_03     ='110'
   AND berd.val_03      =berd1.val_03
   AND  berd.val_30     =berd1.val_30
   AND berd.val_38      IN ('001','002')
   AND berd.val_55      =berd1.val_01)
   )
   ORDER BY berd.person_id;

CURSOR c_get_dup_act (cp_pa_req_id NUMBER
                      ,cp_alt_req_id NUMBER
                     ,cp_date      DATE
                      )
IS
SELECT *
 FROM ghr_pa_requests gpa
WHERE pa_request_id=cp_alt_req_id;

CURSOR c_chk_same_action (cp_request_id NUMBER
                         ,cp_rslt_id     NUMBER
                         )
IS
SELECT berd.*
  FROM  ben_ext_rslt_dtl berd
       ,ben_ext_rslt_dtl berd1
 WHERE berd.request_id  =cp_request_id
   AND berd.request_id  =berd1.request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND berd.ext_rslt_id =berd1.ext_rslt_id
   AND ( (berd.val_03   ='063'
   AND berd.val_03      =berd1.val_03
   AND  berd.val_30     =berd1.val_29
   AND berd.val_29      IN ('001','002')
   AND berd.val_150     =berd1.val_01)
    OR (berd.val_03     ='110'
   AND berd.val_03      =berd1.val_03
   AND  berd.val_30     =berd1.val_30
   AND berd.val_38      IN ('001','002')
   AND berd.val_55      =berd1.val_01)
   )
   ORDER BY berd.person_id;

CURSOR c_get_orig_action_pa (cp_request_id    NUMBER
                            ,cp_rslt_id       NUMBER
                            ,cp_person_id     NUMBER
                            ,cp_noa           VARCHAR2
                            ,cp_pa_request_id VARCHAR2
                           )
IS
SELECT *
  FROM ben_ext_rslt_dtl berd
 WHERE berd.request_id  =cp_request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND berd.val_03   ='063'
   AND berd.person_id=cp_person_id
   AND berd.val_29 =cp_noa
   AND berd.val_01=cp_pa_request_id;

CURSOR c_get_orig_action_aw(cp_request_id    NUMBER
                            ,cp_rslt_id       NUMBER
                            ,cp_person_id     NUMBER
                            ,cp_noa           VARCHAR2
                            ,cp_pa_request_id VARCHAR2
                           )
IS
SELECT *
  FROM ben_ext_rslt_dtl berd
 WHERE berd.request_id  =cp_request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND berd.val_03   ='110'
   AND berd.person_id=cp_person_id
   AND berd.val_30 =cp_noa
   AND berd.val_01=cp_pa_request_id;

l_chk_dup_action   c_chk_dup_action%ROWTYPE;
l_get_dup_act      c_get_dup_act%ROWTYPE;
l_get_orig_action_pa c_get_orig_action_pa%ROWTYPE;
l_get_orig_action_aw  c_get_orig_action_aw%ROWTYPE;
l_flg    VARCHAR2(1);
l_chk_same_action c_chk_same_action%ROWTYPE;
l_person_id   NUMBER;
l_rslt_dtl    ben_ext_rslt_dtl%ROWTYPE;
l_rslt        NUMBER;
TYPE t_rslt_dtl IS TABLE OF ben_ext_rslt_dtl%ROWTYPE
     INDEX BY BINARY_INTEGER;
l_rslt_dtl_pa  t_rslt_dtl;
l_rslt_dtl_aw  t_rslt_dtl;
l_rslt_dtl_tmp  t_rslt_dtl;
l_count   NUMBER;
l_upd_flg  VARCHAR2(1);
l_proc_name     Varchar2(150) := g_proc_name ||'.chk_same_day_act';

BEGIN
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);

 OPEN c_chk_dup_action (p_request_id
                         ,p_rslt_id
                         );
 LOOP
  FETCH c_chk_dup_action INTO l_chk_dup_action;
  EXIT WHEN c_chk_dup_action%NOTFOUND;
   OPEN c_get_dup_act (l_chk_dup_action.val_01
                       ,l_chk_dup_action.val_150
                       ,ghr_us_nfc_extracts.g_ext_start_dt
                      );
    FETCH c_get_dup_act INTO l_get_dup_act;

/*The extract pulls two records when the correction is done for
  the original action, one of orginial and other one of correction.
  since the orginal action would have already been transmitted
  if it both actions have not happened on the same day.
  Since we dont need to send the original action, it has to be
  deleted and the only way to know that the original action
  has been created before the current tranmission date is to look at
  approval date.
  Caveat is there could be an approval date for future action and
  this may happen in a very rare case.
*/
    IF TRUNC(l_get_dup_act.approval_date) < ghr_us_nfc_extracts.g_ext_start_dt THEN
     DELETE from  ben_ext_rslt_dtl berd
      WHERE berd.request_id=p_request_id
        AND berd.ext_rslt_id=p_rslt_id
        AND berd.person_id=l_chk_dup_action.person_id
        AND berd.Val_01 = l_chk_dup_action.val_150;

    END IF;
   CLOSE c_get_dup_act;
 END LOOP;
 CLOSE c_chk_dup_action;

 l_upd_flg :='N';
 l_count :=0;
 l_person_id:=-1;
 l_flg :='O';
 OPEN c_chk_same_action (p_request_id
                         ,p_rslt_id
                         );
 LOOP
 FETCH c_chk_same_action INTO l_chk_same_action;
 EXIT WHEN c_chk_same_action%NOTFOUND;

  IF l_person_id =-1 THEN
   l_person_id:=l_chk_same_action.person_id;
  END IF;

  IF l_chk_same_action.val_03 ='063' THEN
   l_rslt_dtl_pa(l_rslt_dtl_pa.count+1) := l_chk_same_action;
  ELSIF l_chk_same_action.val_03 ='110' THEN
   l_rslt_dtl_aw(l_rslt_dtl_aw.count+1) := l_chk_same_action;
  END IF;

  IF l_chk_same_action.person_id <> l_person_id THEN
   FOR i in 1..l_rslt_dtl_pa.count
   LOOP
    IF  l_rslt_dtl_pa(i).val_29='001' THEN
     DELETE from  ben_ext_rslt_dtl berd
      WHERE berd.request_id=p_request_id
        AND berd.ext_rslt_id=p_rslt_id
        AND berd.person_id=l_person_id
        AND (berd.Val_150 = l_rslt_dtl_pa(i).val_150
             OR berd.val_29=l_rslt_dtl_pa(i).val_150);


    ELSIF  l_rslt_dtl_pa(i).val_29='002'  THEN
     FOR j in 1..l_rslt_dtl_tmp.count
     LOOP
      IF l_rslt_dtl_tmp(j).val_150 =l_rslt_dtl_pa(i).val_150 THEN
       upd_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl_tmp(j)
          ,p_dat_tab =>l_rslt_dtl_pa(i)
          ) ;

       l_rslt_dtl_tmp(j).val_111:=l_rslt_dtl_pa(i).val_111;
       l_upd_flg :='Y' ;
      END IF;
     END LOOP;
     IF l_upd_flg='N' THEN
      l_rslt_dtl_tmp(l_rslt_dtl_tmp.count+1):=l_rslt_dtl_pa(i);
     END IF;
    END IF;
    l_upd_flg:='N';
   END LOOP;


   FOR k in 1..l_rslt_dtl_tmp.count
   LOOP
    OPEN c_get_orig_action_pa (p_request_id
                            ,p_rslt_id
                            ,l_rslt_dtl_tmp(k).person_id
                            ,l_rslt_dtl_tmp(k).val_29
                            ,l_rslt_dtl_tmp(k).val_150
                           );
    FETCH c_get_orig_action_pa INTO l_rslt_dtl;
     upd_Rslt_Dtl
      (p_val_tab     =>l_rslt_dtl_tmp(k)
      ,p_dat_tab =>l_rslt_dtl
      ) ;
     ins_Rslt_Dtl
      (p_val_tab     =>l_rslt_dtl_tmp(k)
      ,p_rslt_dtl_id =>l_rslt
      ) ;
    CLOSE c_get_orig_action_pa;
    DELETE from ben_ext_rslt_dtl berd
     WHERE berd.ext_rslt_dtl_id IN (l_rslt_dtl.ext_rslt_dtl_id
                                  ,l_rslt_dtl_tmp(k).ext_rslt_dtl_id);
   END LOOP;

   IF l_rslt_dtl_pa.count > 0 THEN
   l_rslt_dtl_pa.delete;
   END IF;
   IF l_rslt_dtl_tmp.count > 0 THEN
    l_rslt_dtl_tmp.delete;
   END IF;


 Hr_Utility.set_location('Check for award duplicate row', 5);

   ---Check for award duplicate row
   FOR i in 1..l_rslt_dtl_aw.count
   LOOP
    IF  l_rslt_dtl_aw(i).val_38='001' THEN
     DELETE from  ben_ext_rslt_dtl berd
      WHERE berd.request_id=p_request_id
        AND berd.ext_rslt_id=p_rslt_id
        AND berd.person_id=l_person_id
        AND (berd.Val_55 = l_rslt_dtl_aw(i).val_55
             OR berd.val_38=l_rslt_dtl_aw(i).val_55);


    ELSIF  l_rslt_dtl_aw(i).val_38='002'  THEN
     FOR j in 1..l_rslt_dtl_tmp.count
     LOOP
      IF l_rslt_dtl_tmp(j).val_55 =l_rslt_dtl_aw(i).val_55 THEN
       upd_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl_tmp(j)
          ,p_dat_tab =>l_rslt_dtl_aw(i)
          ) ;
       l_rslt_dtl_tmp(j).val_49 :=l_rslt_dtl_aw(i).val_49;
       l_upd_flg :='Y' ;
      END IF;
      IF l_upd_flg='N' THEN
      l_rslt_dtl_tmp(l_rslt_dtl_tmp.count+1):=l_rslt_dtl_aw(i);
      END IF;
     END LOOP;
    END IF;
    l_upd_flg:='N';
   END LOOP;

   FOR k in 1..l_rslt_dtl_tmp.count
   LOOP
    OPEN c_get_orig_action_pa (p_request_id
                            ,p_rslt_id
                            ,l_rslt_dtl_tmp(k).person_id
                            ,l_rslt_dtl_tmp(k).val_38
                            ,l_rslt_dtl_tmp(k).val_55
                           );
    FETCH c_get_orig_action_pa INTO l_rslt_dtl;
     upd_Rslt_Dtl
        (p_val_tab     =>l_rslt_dtl_tmp(k)
        ,p_dat_tab     =>l_rslt_dtl
         ) ;

     ins_Rslt_Dtl
        (p_val_tab     =>l_rslt_dtl_tmp(k)
        ,p_rslt_dtl_id =>l_rslt
        ) ;

    CLOSE c_get_orig_action_pa;
    DELETE from ben_ext_rslt_dtl berd
     WHERE berd.ext_rslt_dtl_id IN (l_rslt_dtl.ext_rslt_dtl_id
                                   ,l_rslt_dtl_tmp(k).ext_rslt_dtl_id);

   END LOOP;
   IF l_rslt_dtl_aw.count > 0 THEN
   l_rslt_dtl_aw.delete;
   END IF;
   IF l_rslt_dtl_tmp.count > 0 THEN
    l_rslt_dtl_tmp.delete;
   END IF;
  END IF;

  IF l_person_id<> l_chk_same_action.person_id THEN
   l_person_id:=l_chk_same_action.person_id;
   l_count :=0;
  END IF;
 END LOOP;
 CLOSE c_chk_same_action;

 Hr_Utility.set_location('check for remaining data', 5);
----check for remaining data
 IF l_rslt_dtl_pa.count > 0 THEN
  FOR i in 1..l_rslt_dtl_pa.count
   LOOP
    IF  l_rslt_dtl_pa(i).val_29='001' THEN
     DELETE from  ben_ext_rslt_dtl berd
      WHERE berd.request_id=p_request_id
        AND berd.ext_rslt_id=p_rslt_id
        AND berd.person_id=l_person_id
        AND (berd.Val_150 = l_rslt_dtl_pa(i).val_150
             OR berd.val_01=l_rslt_dtl_pa(i).val_150);


    ELSIF  l_rslt_dtl_pa(i).val_29='002'  THEN
     FOR j in 1..l_rslt_dtl_tmp.count
     LOOP
      IF l_rslt_dtl_tmp(j).val_150 =l_rslt_dtl_pa(i).val_150 THEN
       upd_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl_tmp(j)
          ,p_dat_tab =>l_rslt_dtl_pa(i)
          ) ;
       l_rslt_dtl_tmp(j).val_111:=l_rslt_dtl_pa(i).val_111;
       l_upd_flg :='Y' ;
      END IF;
     END LOOP;
     IF l_upd_flg='N' THEN
      l_rslt_dtl_tmp(l_rslt_dtl_tmp.count+1):=l_rslt_dtl_pa(i);
     END IF;
    END IF;
    l_upd_flg:='N';
   END LOOP;
 FOR k in 1..l_rslt_dtl_tmp.count
   LOOP
    OPEN c_get_orig_action_pa (p_request_id
                            ,p_rslt_id
                            ,l_rslt_dtl_tmp(k).person_id
                            ,l_rslt_dtl_tmp(k).val_30
                            ,l_rslt_dtl_tmp(k).val_150
                           );
    FETCH c_get_orig_action_pa INTO l_rslt_dtl;
     upd_Rslt_Dtl
      (p_val_tab     =>l_rslt_dtl_tmp(k)
      ,p_dat_tab =>l_rslt_dtl
      ) ;
     l_rslt_dtl_tmp(k).val_29:=l_rslt_dtl_tmp(k).val_30;
     l_rslt_dtl_tmp(k).val_30:=NULL;
     l_rslt_dtl_tmp(k).val_150:=NULL;

     ins_Rslt_Dtl
      (p_val_tab     =>l_rslt_dtl_tmp(k)
      ,p_rslt_dtl_id =>l_rslt
      ) ;
    CLOSE c_get_orig_action_pa;
    DELETE from ben_ext_rslt_dtl berd
     WHERE (berd.ext_rslt_dtl_id IN (l_rslt_dtl.ext_rslt_dtl_id)
       OR berd.val_150 =l_rslt_dtl.val_01)
       AND berd.ext_rslt_dtl_id NOT IN (
                                  l_rslt_dtl_tmp(k).ext_rslt_dtl_id);
   END LOOP;

   IF l_rslt_dtl_pa.count > 0 THEN
   l_rslt_dtl_pa.delete;
   END IF;
   IF l_rslt_dtl_tmp.count > 0 THEN
    l_rslt_dtl_tmp.delete;
   END IF;
 END IF;
 IF l_rslt_dtl_aw.count > 0 THEN
  FOR i in 1..l_rslt_dtl_aw.count
   LOOP
    IF  l_rslt_dtl_aw(i).val_38='001' THEN
     DELETE from  ben_ext_rslt_dtl berd
      WHERE berd.request_id=p_request_id
        AND berd.ext_rslt_id=p_rslt_id
        AND berd.person_id=l_person_id
        AND (berd.Val_55 = l_rslt_dtl_aw(i).val_55
             OR berd.val_38=l_rslt_dtl_aw(i).val_55);


    ELSIF  l_rslt_dtl_aw(i).val_38='002'  THEN
     FOR j in 1..l_rslt_dtl_tmp.count
     LOOP
      IF l_rslt_dtl_tmp(j).val_55 =l_rslt_dtl_aw(i).val_55 THEN
       upd_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl_tmp(j)
          ,p_dat_tab =>l_rslt_dtl_aw(i)
          ) ;
       l_rslt_dtl_tmp(j).val_49:=l_rslt_dtl_aw(i).val_49;
       l_upd_flg :='Y' ;
      END IF;
      IF l_upd_flg='N' THEN
       l_rslt_dtl_tmp(l_rslt_dtl_tmp.count+1):=l_rslt_dtl_aw(i);
      END IF;
     END LOOP;
    END IF;
      l_upd_flg:='N';
   END LOOP;
 FOR k in 1..l_rslt_dtl_tmp.count
   LOOP
    OPEN c_get_orig_action_pa (p_request_id
                            ,p_rslt_id
                            ,l_rslt_dtl_tmp(k).person_id
                            ,l_rslt_dtl_tmp(k).val_38
                            ,l_rslt_dtl_tmp(k).val_55
                           );
    FETCH c_get_orig_action_pa INTO l_rslt_dtl;
     upd_Rslt_Dtl
        (p_val_tab     =>l_rslt_dtl_tmp(k)
        ,p_dat_tab     =>l_rslt_dtl
         ) ;

     ins_Rslt_Dtl
        (p_val_tab     =>l_rslt_dtl_tmp(k)
        ,p_rslt_dtl_id =>l_rslt
        ) ;

    CLOSE c_get_orig_action_pa;
    DELETE from ben_ext_rslt_dtl berd
     WHERE berd.ext_rslt_dtl_id IN (l_rslt_dtl.ext_rslt_dtl_id
                                   ,l_rslt_dtl_tmp(k).ext_rslt_dtl_id);

   END LOOP;
   IF l_rslt_dtl_aw.count > 0 THEN
   l_rslt_dtl_aw.delete;
   END IF;
   IF l_rslt_dtl_tmp.count > 0 THEN
    l_rslt_dtl_tmp.delete;
   END IF;
 END IF;
-------
  Hr_Utility.set_location('Leaving :'||l_proc_name, 5);

END;






---============================================================================
--PROCEDURE chk_for_err_data_pa
--Check if the error data is present in the error table and then does series
--of checks to see if the error data has been included or not, if included it checks
--for the nature of action code .
---===========================================================================
PROCEDURE chk_for_err_data_pa (p_request_id     IN NUMBER
                                ,p_rslt_id        IN NUMBER
                               )
IS

CURSOR c_chk_err_exist
IS
SELECT count(err_doc_type) cnt
      ,gpid.err_doc_type doc_typ
  FROM ghr_pa_interface_err_dtls gpid
 WHERE gpid.err_doc_type IN ('063','110','347')

GROUP BY gpid.err_doc_type;


CURSOR c_chk_add_in_file
IS
SELECT gpid.person_id
      ,gpid.result_dtl_id
      ,gpid.result_id
      ,gpid.ext_request_id
	  ,gpid.pa_interface_err_dtl_id
 FROM  ghr_pa_interface_err_dtls gpid
WHERE  gpid.err_doc_type='347'
  AND  NOT EXISTS
  (SELECT 'Xl'
    FROM ben_ext_rslt_dtl berd
   WHERE berd.person_id=gpid.person_id
     AND berd.val_03=gpid.err_doc_type
     AND berd.request_id=p_request_id
     AND berd.ext_rslt_id=p_rslt_id);


---get previous value from the ext result for address

CURSOR c_get_prev_val_add (cp_person_id     NUMBER
                          ,cp_result_dtl_id NUMBER
                          ,cp_request_id    NUMBER
                          ,cp_rslt_id       NUMBER
                          )
IS
SELECT *
  FROM  ben_ext_rslt_dtl berd
 WHERE berd.person_id=cp_person_id
   AND berd.ext_rslt_dtl_id = cp_result_dtl_id
   AND berd.val_03='347'
   AND berd.request_id=cp_request_id
   AND berd.ext_rslt_id=cp_rslt_id;

--check for pers action
CURSOR c_chk_data_in_file (cp_doc_typ  VARCHAR2)
IS
SELECT gpid.person_id
      ,gpid.ext_request_id
      ,gpid.result_id
      ,gpid.result_dtl_id
      ,gpid.record_id
      ,gpid.pa_request_id
      ,gpid.err_doc_type
      ,gpid.err_ssn_no
      ,gpid.err_agency
      ,gpid.err_dept_code
      ,gpid.nat_act_1st_3_pos
      ,gpid.nat_act_2nd_3_pos
      ,gpid.alt_pa_request_id
      ,gpid.err_eff_dt
      ,gpid.err_auth_dt
      ,NULL request_id
      ,NULL alt_req_id
      ,NULL  noa1
      ,NULL  noa2
      ,NULL  ext_rslt_dtl_id
      ,NULL  ex_ssno
      ,NULL ex_eff_dt
      ,NULL ex_auth_dt
      ,NULL ex_agncy
      ,NULL dept_code
      ,NULL ext_doc_typ
      ,NULL business_group_id
      ,'N' identifier
	  ,gpid.pa_interface_err_dtl_id
 FROM ghr_pa_interface_err_dtls gpid
 WHERE gpid.err_doc_type=cp_doc_typ
   AND  NOT EXISTS
 (SELECT 'X'
    FROM ben_ext_rslt_dtl berd
  WHERE gpid.person_id=berd.person_id
   AND gpid.err_doc_type=berd.val_03
  AND (gpid.nat_act_1st_3_pos = berd.val_29
   OR gpid.nat_act_1st_3_pos=berd.val_30 )
  AND berd.ext_rcd_id=gpid.record_id
  AND gpid.pa_request_id=NVL(berd.val_150,gpid.pa_request_id)
  AND berd.request_id=p_request_id
  AND berd.ext_rslt_id=p_rslt_id
  )
UNION
SELECT gpid.person_id
      ,gpid.ext_request_id
      ,gpid.result_id
      ,gpid.result_dtl_id
      ,gpid.record_id
      ,gpid.pa_request_id
      ,gpid.err_doc_type
      ,gpid.err_ssn_no
      ,gpid.err_agency
      ,gpid.err_dept_code
      ,gpid.nat_act_1st_3_pos
      ,gpid.nat_act_2nd_3_pos
      ,gpid.alt_pa_request_id
      ,gpid.err_eff_dt
      ,gpid.err_auth_dt
      ,berd.request_id
      ,berd.val_150 alt_req_id
      ,berd.val_29  noa1
      ,berd.val_30  noa2
      ,berd.ext_rslt_dtl_id ext_rslt_dtl_id
      ,val_07 ex_ssno
      ,val_34 ex_eff_dt
      ,val_111 ex_auth_dt
      ,val_04 ex_agncy
      ,val_10 dept_code
      ,berd.val_03  ext_doc_typ
      ,berd.business_group_id
      ,DECODE(berd.val_29,'001','D','002','C') identifier
	  ,gpid.pa_interface_err_dtl_id
 FROM ghr_pa_interface_err_dtls gpid
     ,ben_ext_rslt_dtl berd
WHERE gpid.err_doc_type=cp_doc_typ
  AND  gpid.person_id=berd.person_id
  AND gpid.err_doc_type=berd.val_03
  AND berd.val_29 IN ( '001','002')
  AND gpid.nat_act_1st_3_pos = berd.val_30
  AND gpid.pa_request_id = berd.val_150
  AND berd.ext_rcd_id=gpid.record_id
  AND berd.request_id=p_request_id
  AND berd.ext_rslt_id=p_rslt_id;

---Chk for award
CURSOR c_chk_data_in_file_aw
IS
SELECT gpid.person_id
      ,gpid.ext_request_id
      ,gpid.result_id
      ,gpid.result_dtl_id
      ,gpid.record_id
      ,gpid.pa_request_id
      ,gpid.err_doc_type
      ,gpid.err_ssn_no
      ,gpid.err_agency
      ,gpid.err_dept_code
      ,gpid.nat_act_1st_3_pos
      ,gpid.nat_act_2nd_3_pos
      ,gpid.alt_pa_request_id
      ,gpid.err_eff_dt
      ,gpid.err_auth_dt
      ,NULL request_id
      ,NULL alt_req_id
      ,NULL  noa1
      ,NULL  noa2
      ,NULL  ext_rslt_dtl_id
      ,NULL  ex_ssno
      ,NULL ex_eff_dt
      ,NULL ex_auth_dt
      ,NULL ex_agncy
      ,NULL dept_code
      ,NULL ext_doc_typ
      ,null business_group_id
      ,'N' identifier
	  ,gpid.pa_interface_err_dtl_id
 FROM ghr_pa_interface_err_dtls gpid
 WHERE gpid.err_doc_type='110'
   AND  NOT EXISTS
 (SELECT 'X'
    FROM ben_ext_rslt_dtl berd
  WHERE gpid.person_id=berd.person_id
  AND gpid.err_doc_type=berd.val_03
  AND (gpid.nat_act_1st_3_pos = berd.val_38
   OR gpid.nat_act_1st_3_pos=berd.val_30 )
  AND berd.ext_rcd_id=gpid.record_id
  AND gpid.pa_request_id=NVL(berd.val_55,gpid.pa_request_id)
  AND berd.request_id=p_request_id
  AND berd.ext_rslt_id=p_rslt_id
  )
UNION
SELECT gpid.person_id
      ,gpid.ext_request_id
      ,gpid.result_id
      ,gpid.result_dtl_id
      ,gpid.record_id
      ,gpid.pa_request_id
      ,gpid.err_doc_type
      ,gpid.err_ssn_no
      ,gpid.err_agency
      ,gpid.err_dept_code
      ,gpid.nat_act_1st_3_pos
      ,gpid.nat_act_2nd_3_pos
      ,gpid.alt_pa_request_id
      ,gpid.err_eff_dt
      ,gpid.err_auth_dt
      ,berd.request_id
      ,berd.val_150 alt_req_id
      ,berd.val_38  noa1
      ,berd.val_30  noa2
      ,berd.ext_rslt_dtl_id ext_rslt_dtl_id
      ,val_09 ex_ssno
      ,val_32 ex_eff_dt
      ,val_48 ex_auth_dt
      ,val_04 ex_agncy
      ,val_10 dept_code
      ,berd.val_03  ext_doc_typ
      ,berd.business_group_id
      ,DECODE(berd.val_38,'001','D','002','C') identifier
	  ,gpid.pa_interface_err_dtl_id
 FROM ghr_pa_interface_err_dtls gpid
     ,ben_ext_rslt_dtl berd
WHERE gpid.err_doc_type='110'
  AND  gpid.person_id=berd.person_id
  AND gpid.err_doc_type=berd.val_03
  AND berd.val_38 IN ( '001','002')
  AND gpid.nat_act_1st_3_pos = berd.val_30
  AND gpid.pa_request_id = berd.val_55
  AND berd.ext_rcd_id=gpid.record_id
  AND berd.request_id=p_request_id
  AND berd.ext_rslt_id=p_rslt_id;
--Get data from the previous sesult.
CURSOR c_get_prev_data (cp_request_id  NUMBER
                     ,cp_rslt_dtl_id NUMBER
                     ,cp_rcd_id      NUMBER
                     ,cp_rslt_id     NUMBER
                     )
IS
SELECT *
  FROM ben_ext_rslt_dtl berd
 WHERE berd.request_id = cp_request_id
   AND berd.ext_rslt_dtl_id = cp_rslt_dtl_id
   AND berd.ext_rslt_id     =cp_rslt_id
   AND berd.ext_rcd_id      =cp_rcd_id
   ;

CURSOR c_get_prev_rmk_data (cp_request_id  NUMBER
                     ,cp_pa_req            VARCHAR2
                     ,cp_person_id         NUMBER
                      )
IS
SELECT *
  FROM ben_ext_rslt_dtl berd
 WHERE berd.request_id = cp_request_id
   AND berd.val_02='RMK'
    AND berd.val_01=cp_pa_req
   AND berd.person_id=cp_person_id
   ;

l_chk_data_in_file_aw c_chk_data_in_file_aw%ROWTYPE;
l_rslt_dtl         ben_ext_rslt_dtl%ROWTYPE;
l_get_prev_data    c_get_prev_data%ROWTYPE;
l_chk_err_exist    c_chk_err_exist%ROWTYPE;
l_chk_data_in_file c_chk_data_in_file%ROWTYPE;
l_get_prev_rmk_data c_get_prev_rmk_data%ROWTYPE;
l_rslt_dtl_id      NUMBER;
l_chk_add_in_file  c_chk_add_in_file%ROWTYPE;
l_rslt_dtl_temp    ben_ext_rslt_dtl%ROWTYPE;
l_proc_name     Varchar2(150) := g_proc_name ||'.c_get_prev_val_add';

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
---Chances of picking a new action is there and need to be tested.
--Ex: when the action comes back as an error and next day there is a cancellation
--and then a same new action is created. Now the error data may pick the new action as same

 OPEN c_chk_err_exist;
 LOOP
  FETCH c_chk_err_exist INTO l_chk_err_exist;
  EXIT WHEN c_chk_err_exist%NOTFOUND;
  IF l_chk_err_exist.doc_typ ='063' THEN
   OPEN c_chk_data_in_file (l_chk_err_exist.doc_typ);
    LOOP
    FETCH c_chk_data_in_file INTO l_chk_data_in_file ;
    EXIT WHEN c_chk_data_in_file%NOTFOUND;
     IF l_chk_data_in_file.identifier ='N' THEN
      OPEN c_get_prev_data (l_chk_data_in_file.ext_request_id
                           ,l_chk_data_in_file.result_dtl_id
                           ,l_chk_data_in_file.record_id
                           ,l_chk_data_in_file.result_id
                           );
      FETCH c_get_prev_data INTO l_rslt_dtl;--l_get_prev_data;
      CLOSE c_get_prev_data;
      l_rslt_dtl.val_02:='S';
      l_rslt_dtl.request_id  :=p_request_id;
      l_rslt_dtl.ext_rslt_id :=p_rslt_id;
     -- l_rslt_dtl.business_group_id :=l_get_prev_data.business_group_id;
       Ins_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl
          ,p_rslt_dtl_id =>l_rslt_dtl_id
          ) ;

      OPEN c_get_prev_rmk_data (l_chk_data_in_file.ext_request_id
                                 ,l_rslt_dtl.val_01
                                 ,l_rslt_dtl.person_id
                                 );
       LOOP
        FETCH c_get_prev_rmk_data INTO l_get_prev_rmk_data;
        EXIT WHEN c_get_prev_rmk_data%NOTFOUND;
        l_get_prev_rmk_data.request_id  :=p_request_id;
        l_get_prev_rmk_data.ext_rslt_id :=p_rslt_id;
        Ins_Rslt_Dtl
          (p_val_tab     =>l_get_prev_rmk_data
          ,p_rslt_dtl_id =>l_rslt_dtl_id
          ) ;
       END LOOP;
       CLOSE c_get_prev_rmk_data;

      l_rslt_dtl:=l_rslt_dtl_temp;
		--- Bug 5012619
	   DELETE FROM ghr_pa_interface_err_dtls perr
       WHERE pa_interface_err_dtl_id = l_chk_data_in_file.pa_interface_err_dtl_id;
	   --
     ELSIF l_chk_data_in_file.identifier='C' THEN
      UPDATE ben_ext_rslt_dtl berd
        SET berd.val_29 = l_chk_data_in_file.nat_act_1st_3_pos
           ,berd.val_30=NULL
           ,berd.val_150=null
       WHERE berd.request_id=p_request_id
         AND berd.ext_rslt_id=p_rslt_id
         AND berd.ext_rcd_id=l_chk_data_in_file.record_id
         AND berd.ext_rslt_dtl_id=l_chk_data_in_file.ext_rslt_dtl_id;


     ELSIF l_chk_data_in_file.identifier='D' THEN
      DELETE FROM ben_ext_rslt_dtl berd
       WHERE berd.ext_rslt_dtl_id=l_chk_data_in_file.ext_rslt_dtl_id;

     END IF;
    END LOOP;
   CLOSE c_chk_data_in_file;
  ELSIF l_chk_err_exist.doc_typ ='110' THEN
   OPEN c_chk_data_in_file_aw ;
    LOOP
    FETCH c_chk_data_in_file_aw INTO l_chk_data_in_file_aw ;
    EXIT WHEN c_chk_data_in_file_aw%NOTFOUND;
     IF l_chk_data_in_file_aw.identifier ='N' THEN
      OPEN c_get_prev_data (l_chk_data_in_file_aw.ext_request_id
                           ,l_chk_data_in_file_aw.result_dtl_id
                           ,l_chk_data_in_file_aw.record_id
                           ,l_chk_data_in_file_aw.result_id
                           );
      FETCH c_get_prev_data INTO l_rslt_dtl;
      CLOSE c_get_prev_data;

      l_rslt_dtl.val_02:='S';
      l_rslt_dtl.request_id  :=p_request_id;
      l_rslt_dtl.ext_rslt_id :=p_rslt_id;

       Ins_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl
          ,p_rslt_dtl_id =>l_rslt_dtl_id
          ) ;

      l_rslt_dtl:=l_rslt_dtl_temp;
	  --- Bug 5012619
	   DELETE FROM ghr_pa_interface_err_dtls perr
       WHERE pa_interface_err_dtl_id = l_chk_data_in_file_aw.pa_interface_err_dtl_id;
	   --
     ELSIF l_chk_data_in_file_aw.identifier='C' THEN
      UPDATE ben_ext_rslt_dtl berd
        SET berd.val_38=NULL
           --,  berd.val_38 = l_chk_data_in_file.nat_act_1st_3_pos
           --,berd.val_30=NULL
           ,berd.val_55=NULL
       WHERE berd.request_id=p_request_id
         AND berd.ext_rslt_id=p_rslt_id
         AND berd.ext_rcd_id=l_chk_data_in_file_aw.record_id
         AND berd.ext_rslt_dtl_id=l_chk_data_in_file_aw.ext_rslt_dtl_id;


     ELSIF l_chk_data_in_file_aw.identifier='D' THEN
      DELETE FROM ben_ext_rslt_dtl berd
       WHERE berd.ext_rslt_dtl_id=l_chk_data_in_file_aw.ext_rslt_dtl_id;

     END IF;
    END LOOP;
   CLOSE c_chk_data_in_file_aw;

  ELSIF l_chk_err_exist.doc_typ='347' THEN
   NULL;
   OPEN c_chk_add_in_file;
   LOOP
    FETCH c_chk_add_in_file INTO l_chk_add_in_file;
    EXIT WHEN c_chk_add_in_file%NOTFOUND;
    OPEN c_get_prev_val_add (l_chk_add_in_file.person_id
                            ,l_chk_add_in_file.result_dtl_id
                            ,l_chk_add_in_file.ext_request_id
                            ,l_chk_add_in_file.result_id
                          );
    FETCH c_get_prev_val_add INTO l_rslt_dtl;
     l_rslt_dtl.val_02:='S';
     l_rslt_dtl.request_id  :=p_request_id;
     l_rslt_dtl.ext_rslt_id :=p_rslt_id;
     Ins_Rslt_Dtl
          (p_val_tab     =>l_rslt_dtl
          ,p_rslt_dtl_id =>l_rslt_dtl_id
          ) ;
	   --- Bug 5012619
	   DELETE FROM ghr_pa_interface_err_dtls perr
       WHERE pa_interface_err_dtl_id = l_chk_add_in_file.pa_interface_err_dtl_id;
	   --
    CLOSE c_get_prev_val_add;
   END LOOP;
   CLOSE c_chk_add_in_file;

  END IF;

 END LOOP;
 CLOSE c_chk_err_exist;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;


---============================================================================
--PROCEDURE chk_for_err_data_pos
---===========================================================================
PROCEDURE chk_for_err_data_pos (p_request_id     IN NUMBER
                                ,p_rslt_id        IN NUMBER
                               )


IS
--Pick from the previous result.
CURSOR c_prev_ext_rslt (cp_request_id      NUMBER
                       ,cp_result_dtl_id   NUMBER
                       ,cp_record_id       NUMBER
                       )
IS
SELECT *
 FROM ben_ext_rslt_dtl berd
WHERE berd.request_id = cp_request_id
  AND berd.ext_rslt_dtl_id=cp_result_dtl_id
  AND berd.ext_rcd_id     =cp_record_id;

--Check error table if the master record exists
CURSOR c_chk_mast_exist
IS
SELECT count(*) cnt
  FROM ghr_pos_interface_err_dtls gpid
 WHERE gpid.susp_mast_indv='2055';
--Check for master error record.
CURSOR c_chk_mast_err
IS
SELECT  berd.val_71 position_id,
        berd.val_26 f_function_cd,
        gpid.susp_function_cd e_function_cd,
		gpid.pos_interface_err_dtl_id
  FROM  ben_ext_rslt_dtl berd
       ,ghr_pos_interface_err_dtls gpid
 WHERE TO_CHAR(gpid.position_id) = berd.val_71
   AND gpid.susp_mast_indv ='2055'
   AND gpid.susp_mast_indv=berd.val_02
   AND berd.request_id=p_request_id
   AND berd.ext_rcd_id=gpid.record_id;

--Check the record that is not is the transmission file.
CURSOR c_chk_unpick_mast
IS
SELECT *
  FROM  ghr_pos_interface_err_dtls gpid
 WHERE NOT EXISTS (
   SELECT 'X'
     FROM ben_ext_rslt_dtl berd
    WHERE to_char(gpid.position_id) = berd.val_71
      AND gpid.susp_mast_indv ='2055'
      AND gpid.susp_mast_indv=berd.val_02
      AND berd.request_id=p_request_id
      AND berd.ext_rcd_id=gpid.record_id)
   AND gpid.susp_mast_indv ='2055';

--Check error table if the detail record exists
CURSOR c_chk_ind_exist
IS
SELECT COUNT(*) cnt
  FROM ghr_pos_interface_err_dtls gpid
 WHERE gpid.susp_mast_indv='2056';

--Check for detail error record.
CURSOR c_chk_ind_err
IS
SELECT  berd.val_71 position_id,
        berd.val_45 f_function_cd,
        gpid.susp_function_cd e_function_cd,
		gpid.pos_interface_err_dtl_id
  FROM  ben_ext_rslt_dtl berd
       ,ghr_pos_interface_err_dtls gpid
 WHERE to_char(gpid.position_id) = berd.val_71
   AND gpid.susp_mast_indv ='2056'
   AND gpid.susp_mast_indv=berd.val_02
   AND berd.request_id=p_request_id
   AND berd.ext_rcd_id=gpid.record_id;


--Check the detail record that is not is the transmission file.
CURSOR c_chk_unpick_ind
IS
SELECT *
  FROM  ghr_pos_interface_err_dtls gpid
 WHERE NOT EXISTS (
   SELECT 'X'
     FROM ben_ext_rslt_dtl berd
    WHERE to_char(gpid.position_id) = berd.val_71
      AND gpid.susp_mast_indv ='2056'
      AND gpid.susp_mast_indv=berd.val_02
      AND berd.request_id=p_request_id
      AND berd.ext_rcd_id=gpid.record_id)
   AND gpid.susp_mast_indv ='2056';


l_chk_unpick_mast  c_chk_unpick_mast%ROWTYPE;
l_chk_mast_exist   c_chk_mast_exist%ROWTYPE;
l_chk_ind_exist    c_chk_ind_exist%ROWTYPE;
l_chk_ind_err      c_chk_ind_err%ROWTYPE;
l_chk_mast_err     c_chk_mast_err%ROWTYPE;
l_rslt_dtl         ben_ext_rslt_dtl%ROWTYPE;
l_prev_ext_rslt    c_prev_ext_rslt%ROWTYPE;
l_rslt_dtl_id      NUMBER;
l_chk_unpick_ind   c_chk_unpick_ind%ROWTYPE;
l_proc_name     Varchar2(150) := g_proc_name ||'.chk_for_err_data_pos';

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
 OPEN c_chk_mast_exist;
 FETCH c_chk_mast_exist INTO l_chk_mast_exist;
 CLOSE c_chk_mast_exist;
 IF l_chk_mast_exist.cnt > 0 THEN
  OPEN c_chk_mast_err;
  LOOP
   FETCH c_chk_mast_err INTO l_chk_mast_err;
   EXIT WHEN c_chk_mast_err%NOTFOUND;
   IF l_chk_mast_err.e_function_cd <> l_chk_mast_err.f_function_cd THEN

    UPDATE ben_ext_rslt_dtl berd
       SET berd.val_26=l_chk_mast_err.e_function_cd
     WHERE berd.val_71 = to_char(l_chk_mast_err.position_id)
       AND berd.request_id=p_request_id
       AND berd.val_02='2055';

   END IF;


  END LOOP;
  CLOSE c_chk_mast_err;

  OPEN c_chk_unpick_mast;
  LOOP
   FETCH c_chk_unpick_mast INTO l_chk_unpick_mast;
   EXIT WHEN c_chk_unpick_mast%NOTFOUND;
   OPEN  c_prev_ext_rslt (l_chk_unpick_mast.request_id
                         ,l_chk_unpick_mast.result_dtl_id
                         ,l_chk_unpick_mast.record_id
                         );
   FETCH c_prev_ext_rslt INTO l_rslt_dtl;
    l_rslt_dtl.val_01 :='S';
    l_rslt_dtl.request_id:=p_request_id;
    l_rslt_dtl.ext_rslt_id:=p_rslt_id;
    Ins_Rslt_Dtl
          (p_val_tab      =>l_rslt_dtl
          ,p_rslt_dtl_id  => l_rslt_dtl_id
          ) ;
   CLOSE c_prev_ext_rslt;
	-- Bug 5012619
	DELETE FROM ghr_pos_interface_err_dtls perr
       WHERE pos_interface_err_dtl_id = l_chk_unpick_mast.pos_interface_err_dtl_id;

  END LOOP;
  CLOSE c_chk_unpick_mast;


 END IF;
--Check for individual record.
 OPEN c_chk_ind_exist;
 FETCH c_chk_ind_exist INTO l_chk_ind_exist;
 CLOSE c_chk_ind_exist;

 IF l_chk_ind_exist.cnt > 0 THEN
  OPEN c_chk_ind_err;
  LOOP
   FETCH c_chk_ind_err INTO l_chk_ind_err;
   EXIT WHEN c_chk_ind_err%NOTFOUND;
   IF l_chk_ind_err.e_function_cd <> l_chk_ind_err.f_function_cd THEN

    UPDATE ben_ext_rslt_dtl berd
       SET berd.val_45=l_chk_ind_err.e_function_cd
     WHERE berd.val_71 =TO_CHAR( l_chk_ind_err.position_id)
       AND berd.request_id=p_request_id
       AND berd.val_02='2056';

   END IF;


  END LOOP;
  CLOSE c_chk_ind_err;

  OPEN c_chk_unpick_ind;
  LOOP
   FETCH c_chk_unpick_ind INTO l_chk_unpick_ind;
   EXIT WHEN c_chk_unpick_ind%NOTFOUND;
   OPEN  c_prev_ext_rslt (l_chk_unpick_ind.request_id
                         ,l_chk_unpick_ind.result_dtl_id
                         ,l_chk_unpick_ind.record_id
                         );
   FETCH c_prev_ext_rslt INTO l_rslt_dtl;
    l_rslt_dtl.val_01 :='S';
    l_rslt_dtl.request_id:=p_request_id;
    l_rslt_dtl.ext_rslt_id:=p_rslt_id;
    Ins_Rslt_Dtl
          (p_val_tab      =>l_rslt_dtl
          ,p_rslt_dtl_id  => l_rslt_dtl_id
          ) ;

   CLOSE c_prev_ext_rslt;
	-- Bug 5012619
	DELETE FROM ghr_pos_interface_err_dtls perr
       WHERE pos_interface_err_dtl_id = l_chk_unpick_ind.pos_interface_err_dtl_id;

  END LOOP;
  CLOSE c_chk_unpick_ind;

 END IF;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;
---============================================================================
--PROCEDURE populate_pa_error_tab
---===========================================================================

PROCEDURE populate_pa_error_tab (p_request_id     IN NUMBER
                             ,p_record_id         IN NUMBER
                             ,p_person_id         IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_status            IN VARCHAR2
                             ,p_indicator         IN VARCHAR2
                             ,p_department_code   IN VARCHAR2
                             ,p_agency_code       IN VARCHAR2
                             ,p_poi               IN VARCHAR2
                             ,p_ssn               IN VARCHAR2
                             ,p_pay_per_num       IN VARCHAR2
                             ,p_auth_dt           IN VARCHAR2
                             ,p_noa1              IN VARCHAR2
                             ,p_noa2              IN VARCHAR2
                             ,p_eff_dt            IN VARCHAR2
                             ,p_doc_typ           IN VARCHAR2
                             )
IS
TYPE curtyp is ref cursor;
l_cur       curtyp;
l_result_dtl_id   NUMBER;
l_result_id       NUMBER;
l_rcd_id          NUMBER;
l_indicator       VARCHAR2(4);
l_department_code VARCHAR2(20);
l_agency_code     VARCHAR2(20);
l_poi             VARCHAR2(40);
l_ssn             VARCHAR2(90);
l_noa1            VARCHAR2(30);
l_noa2            VARCHAR2(30);
l_pay_per_num     VARCHAR2(20);
l_auth_dt         VARCHAR2(20);
l_doc_typ         VARCHAR2(30);
l_eff_dt          VARCHAR2(20);
l_stmt            VARCHAR2(4000);
l_person_id       NUMBER;
l_pa_req          VARCHAR2(20);
BEGIN
l_stmt := 'select  ext_rslt_dtl_id
           , ext_rslt_id
           ,ext_rcd_id
           ,val_01
           ,person_id'||','
           ||p_indicator ||','
           ||p_department_code||','
           ||p_agency_code||','
           ||p_poi||','
           ||p_ssn||','
           ||p_noa1||','
           ||p_noa2||','
           ||p_pay_per_num||','
           ||p_auth_dt||','
           ||p_doc_typ||','
           ||p_eff_dt||
           '  from ben_ext_rslt_dtl
              where request_id     = :1
                and ext_rcd_id     = :2
                and '||p_status||'  = '||'''E''' ;

--insert into a values (l_stmt);
 open l_cur for l_stmt
  using p_request_id
        ,p_record_id;

  LOOP
   fetch l_cur into l_result_dtl_id
                        ,l_result_id
                        ,l_rcd_id
                        ,l_pa_req
                        ,l_person_id
                        ,l_indicator
                        ,l_department_code
                        ,l_agency_code
                        ,l_poi
                        ,l_ssn
                        ,l_noa1
                        ,l_noa2
                        ,l_pay_per_num
                        ,l_auth_dt
                        ,l_doc_typ
                        ,l_eff_dt
                         ;
  EXIT WHEN l_cur%NOTFOUND;
  IF l_indicator ='110' THEN
   IF l_noa1 IS NULL THEN

    l_noa1 := l_noa2;
    l_noa2:=NULL;
   END IF;

  END IF;
  INSERT INTO ghr_pa_interface_err_dtls
  (         pa_interface_err_dtl_id
           ,ext_request_id
           ,result_id
           ,result_dtl_id
           ,record_id
           ,business_group_id
           ,person_id
           ,assignment_id
           ,pa_request_id
           ,err_ssn_no
           ,err_agency
           ,err_emp_off
           ,err_dept_code
           ,err_doc_type
           ,err_pay_period
           ,err_auth_dt
           ,nat_act_1st_3_pos
           ,nat_act_2nd_3_pos
           ,err_eff_dt
           ,err_batch_no
           ,err_oper_code
           ,error_code
           ,error_msg
           ,error_element_name
           ,error_elem_content
 )
 VALUES
  (
           ghr_pa_interface_err_dtls_s.nextval
           ,p_request_id
           ,l_result_id
           ,l_result_dtl_id
           ,p_record_id
           ,null
           ,l_person_id
           ,null
           ,l_pa_req
           ,l_ssn
           ,l_agency_code
           ,l_poi
           ,l_department_code
           ,l_indicator
           ,l_pay_per_num
           ,l_auth_dt
           ,l_noa1
           ,l_noa2
           ,l_eff_dt
           ,l_doc_typ
           ,null
           ,null
           ,null
           ,null
           ,null
           );

  END LOOP;
 CLOSE l_cur;
END;
---============================================================================

---===========================================================================

PROCEDURE populate_pos_error_tab (p_request_id        IN NUMBER
                             ,p_record_id         IN NUMBER
                             ,p_position_id       IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_status            IN VARCHAR2
                             ,p_indicator         IN VARCHAR2
                             ,p_function_code     IN VARCHAR2
                             ,p_department_code   IN VARCHAR2
                             ,p_agency_code       IN VARCHAR2
                             ,p_poi               IN VARCHAR2
                             ,p_mrn               IN VARCHAR2
                             ,p_grade             IN VARCHAR2
                             ,p_pos_num           IN VARCHAR2
                             ,p_incumbant_ssn     IN VARCHAR2
                             ,p_oblig_ssn         IN VARCHAR2
                            )
IS

TYPE curtyp is ref cursor;
l_cur       curtyp;
l_indicator VARCHAR2(11) ;
l_function_code VARCHAR2(12);
l_agency_code   VARCHAR2(12);
l_poi           VARCHAR2(12);
l_mrn           VARCHAR2(16);
l_grade         VARCHAR2(12);
l_department_code VARCHAR2(12);
l_stmt   varchar2(4000);
l_result_dtl_id    NUMBER;
l_result_id        NUMBER;
l_rcd_id           NUMBER;
l_pos_num          VARCHAR2(8);
l_incumbant_ssn    VARCHAR2(9);
l_position_id      VARCHAR2(9);
l_proc_name     Varchar2(150) := g_proc_name ||'.populate_pos_error_tab';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

 l_stmt := 'select  ext_rslt_dtl_id
           , ext_rslt_id
           ,ext_rcd_id
           ,val_71'||','
           ||p_indicator ||','
           ||p_function_code||','
           ||p_department_code||','
           ||p_agency_code||','
           ||p_poi||','
           ||p_mrn||','
           ||p_grade||','
           ||p_pos_num||','
           ||p_incumbant_ssn||
           '  from ben_ext_rslt_dtl
              where request_id     = :1
                and ext_rcd_id     = :2
              	and '||p_status||'  = '||'''E''' ;
  open l_cur for l_stmt
  using p_request_id
        ,p_record_id;
  LOOP
  	fetch l_cur into l_result_dtl_id
                        ,l_result_id
                        ,l_rcd_id
                        ,l_position_id
                         ,l_indicator
                         ,l_function_code
                         ,l_department_code
                         ,l_agency_code
                         ,l_poi
                         ,l_mrn
                         ,l_grade
                         ,l_pos_num
                         ,l_incumbant_ssn
                         ;

  EXIT WHEN l_cur%NOTFOUND;
  INSERT INTO ghr_pos_interface_err_dtls
    ( pos_interface_err_dtl_id
     ,request_id
     ,result_id
     ,result_dtl_id
     ,record_id
     ,business_group_id
     ,position_id
     ,susp_user_id
     ,susp_mast_indv
     ,susp_function_cd
     ,susp_dept
     ,susp_agcy
     ,susp_poi
     ,susp_mast_rec_num
     ,susp_grd
     ,susp_indv_pos_num
     ,susp_incum_ssn
     ,susp_oblig_ssn
     ,susp_pay_period
     ,susp_pass_num
     ,susp_error_msg_num
     ,susp_error_msg
     ,susp_elem_name_num
     ,susp_elem_name
     ,susp_data_field
     ,susp_serv_agcy
      )
    VALUES
      (ghr_pos_interface_err_dtls_s.nextval
      ,p_request_id
      ,l_result_id
      ,l_result_dtl_id
      ,p_record_id
      ,null
      ,TO_NUMBER(l_position_id)
      ,null
      ,l_indicator
      ,l_function_code
      ,l_department_code
      ,l_agency_code
      ,l_poi
      ,l_mrn
      ,l_grade
      ,l_pos_num
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      );
 END LOOP;
  close l_cur;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;



-- =============================================================================
-- ~ NFC_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE NFC_Error_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_business_group_id           IN  NUMBER
           ,p_file_type                   IN  VARCHAR2
           ,p_pos_dummy                   IN  VARCHAR2
           ,p_pa_dummy                    IN  VARCHAR2
           ,p_dummy                       IN  VARCHAR2
           ,p_request_id                  IN  NUMBER
           )

IS

CURSOR c_get_info_mast
IS
 select beder.seq_num
       ,bede.string_val
       ,ber.ext_rcd_id record_id
  from ben_ext_rslt  bes
      ,ben_ext_dfn  bed
      ,ben_ext_file bef
      ,ben_ext_rcd_in_file  berf
      ,ben_ext_rcd  ber
      ,ben_ext_data_elmt_in_rcd   beder
      ,ben_ext_data_elmt  bede
 where bes.request_id=p_request_id
   and   bes.ext_dfn_id=bed.ext_dfn_id
   and bed.ext_file_id =bef.ext_file_id
   and bef.ext_file_id=berf.ext_file_id
   and ber.ext_rcd_id = berf.ext_rcd_id
  /* and (ber.name like '%SHRL Master Position Data Element Record - (NFC PO)'
    OR  ber.name like '%SHRL Detail Position Data Element Record - (NFC PO)'
    OR  ber.name like 'DRL Individual Data Element Record - (NFC PO)')*/
   and ber.ext_rcd_id=beder.ext_rcd_id
   and bede.ext_data_elmt_id = beder.ext_data_elmt_id
   and bede.string_val in ('S','Master Record Number06','2055'
                            ,'Function Code26','Function Code46','Department Code03'
                            ,'Agency Code04','Personnel Office Identifier05'
                            ,'Grade07','2056','Position Number08','IncumbentSSN50')
   ORDER BY ber.ext_rcd_id;



CURSOR c_get_pa_info
IS
select beder.seq_num
       ,bede.string_val
       ,ber.ext_rcd_id record_id
  from ben_ext_rslt  bes
      ,ben_ext_dfn  bed
      ,ben_ext_file bef
      ,ben_ext_rcd_in_file  berf
      ,ben_ext_rcd  ber
      ,ben_ext_data_elmt_in_rcd   beder
      ,ben_ext_data_elmt  bede
 where bes.request_id=p_request_id
   and   bes.ext_dfn_id=bed.ext_dfn_id
   and bed.ext_file_id =bef.ext_file_id
   and bef.ext_file_id=berf.ext_file_id
   and ber.ext_rcd_id = berf.ext_rcd_id
--   and (ber.name like '%DRL Personnel Actions [RPA] - (NFC PA)'
--    OR  ber.name like '%DRL Personnel Actions Remarks [RMK] - (NFC PA)'
--    OR  ber.name like 'DRL Personnel Actions Awards [AWD] - (NFC PA)'
 --   OR ber.name like '%DRL Address Change Record [ADD] - (NFC PA)')
   and ber.ext_rcd_id=beder.ext_rcd_id
   and bede.ext_data_elmt_id = beder.ext_data_elmt_id
   and bede.string_val in ('S','RPA_SSN','RPA_NFC_AGENCY','RPA_POI','RPA_PMSO_DEPT','063'
                           ,'RPA_PAY_PERIOD_NUM','RPA_AUTH_DT','RPA_SEC_NOA_CD',
                           'RPA_FIRST_NOA_CD','RPA_EFF_DATE','6700','110','347','REM_SSN',
                            'REM_AGNCY_CD','REM_POI','REM_PAY_PER_NUM','REM_DEPT_CD','AWD_AUTH_DT'
                            ,'AWD_PERS_EFF_DT','AWD_NAT_ACT_POS1','AWD_NAT_ACT_POS2',
                            'ADD_AGNCY_CD','ADD_POI','ADD_SSN','ADD_PAY_PER_NUM','ADD_DEPT_CODE'
                            )
  ORDER BY ber.ext_rcd_id;
/*CURSOR c_get_info_ind
IS
 select beder.seq_num
       ,bede.string_val
       ,ber.ext_rcd_id record_id
  from ben_ext_rslt  bes
      ,ben_ext_dfn  bed
      ,ben_ext_file bef
      ,ben_ext_rcd_in_file  berf
      ,ben_ext_rcd  ber
      ,ben_ext_data_elmt_in_rcd   beder
      ,ben_ext_data_elmt  bede
 where bes.request_id=p_request_id
   and   bes.ext_dfn_id=bed.ext_dfn_id
   and bed.ext_file_id =bef.ext_file_id
   and bef.ext_file_id=berf.ext_file_id
   and ber.ext_rcd_id = berf.ext_rcd_id
   and ( ber.name like '%SHRL Detail Position Data Element Record - (NFC PO)'
    OR  ber.name like 'DRL Individual Data Element Record - (NFC PO)'
   and ber.ext_rcd_id=beder.ext_rcd_id
   and bede.ext_data_elmt_id = beder.ext_data_elmt_id
   and bede.string_val in ('S','Master Record Number06','2056'
                            ,'Function Code26','Department Code03'
                            ,'Agency Code04','Personnel Office Identifier05'
                            ,'Grade07','Position Number08','Incumbent SSN50');
*/


l_get_info c_get_info_mast%ROWTYPE;
--l_get_info_ind c_get_info_ind%ROWTYPE;
l_get_pa_info c_get_pa_info%ROWTYPE;
l_val   VARCHAR2(30);
l_val1  VARCHAR2(30);
TYPE r_attr IS RECORD (
 status             VARCHAR2(10)
,indicator          VARCHAR2(10)
,function_code      VARCHAR2(10)
,department_code    VARCHAR2(10)
,agency_code        VARCHAR2(10)
,poi                VARCHAR2(10)
,mrn                VARCHAR2(10)
,grade              VARCHAR2(10)
,pos_num            VARCHAR2(10)
,incumbant_ssn      VARCHAR2(10)
,oblig_ssn          VARCHAR2(10)
,pay_per_num        VARCHAR2(10)
);

TYPE r_attr_pa IS RECORD (
 status             VARCHAR2(10)
,indicator          VARCHAR2(10)
,person_id          number
,department_code    VARCHAR2(10)
,agency_code        VARCHAR2(10)
,poi                VARCHAR2(10)
,mrn                VARCHAR2(10)
,pos_num            VARCHAR2(10)
,ssno               VARCHAR2(10)
,oblig_ssn          VARCHAR2(10)
,pay_per_num        VARCHAR2(10)
,auth_dt            VARCHAr2(10)
,noa1               VARCHAR2(10)
,noa2               VARCHAR2(10)
,eff_dt             VARCHAR2(10)
,doc_typ            VARCHAr2(10)
);


TYPE t_attr IS TABLE OF r_attr
  INDEX BY binary_integer;
TYPE t_attr_pa IS TABLE OF r_attr_pa
  INDEX BY binary_integer;
l_attr               t_attr;
l_attr_pa            t_attr_pa;
l_status             VARCHAR2(10):='NULL';
l_indicator          VARCHAR2(10):='NULL';
l_function_code      VARCHAR2(10):='NULL';
l_department_code    VARCHAR2(10):='NULL';
l_agency_code        VARCHAR2(10):='NULL';
l_poi                VARCHAR2(10):='NULL';
l_mrn                VARCHAR2(10):='NULL';
l_grade              VARCHAR2(10):='NULL';
l_pos_num            VARCHAR2(10):='NULL';
l_incumbant_ssn      VARCHAR2(10):='NULL';
l_oblig_ssn          VARCHAR2(10):='NULL';
l_pay_per_num        VARCHAR2(10):='NULL';
l_auth_dt            VARCHAR2(10):='NULL';
l_noa1               VARCHAR2(10);
l_noa2               VARCHAR2(10);
l_eff_dt             VARCHAR2(10);
l_doc_typ            VARCHAR2(10);
l_temp_rcd_id        NUMBER;
l_count   NUMBER;
l_count1   NUMBER;
l_proc_name     Varchar2(150) := g_proc_name ||'.NFC_Error_Process';
BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);

 l_temp_rcd_id :=-1;
 l_val:='VAL_';
 l_val1:='VAL_0';

 IF p_file_type='PMSO' THEN
  DELETE FROM  ghr_pos_interface_err_dtls;
  OPEN c_get_info_mast;
  LOOP
   FETCH c_get_info_mast INTO l_get_info;
   EXIT WHEN c_get_info_mast%NOTFOUND;
   IF l_temp_rcd_id <> l_get_info.record_id THEN
    l_temp_rcd_id := l_get_info.record_id;
   END IF;
   IF l_get_info.string_val='S' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).status := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).status := l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val='Master Record Number06' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).mrn :=l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).mrn:= l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val='2055' OR l_get_info.string_val='2056' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).indicator  := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).indicator  := l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val='Function Code26'
      OR l_get_info.string_val='Function Code46' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).function_code   := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).function_code   := l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val='Department Code03' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).department_code := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).department_code := l_val1||l_get_info.seq_num;
    END IF;

   ELSIF l_get_info.string_val='Agency Code04' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).agency_code := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).agency_code := l_val1||l_get_info.seq_num;
    END IF;

   ELSIF l_get_info.string_val= 'Personnel Office Identifier05' THEN

    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).poi := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).poi := l_val1||l_get_info.seq_num;
    END IF;

   ELSIF l_get_info.string_val= 'Grade07' THEN

    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).grade := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).grade := l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val= 'Position Number08' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).pos_num := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).pos_num := l_val1||l_get_info.seq_num;
    END IF;
   ELSIF l_get_info.string_val= 'IncumbentSSN50' THEN
    IF l_get_info.seq_num >10 THEN
     l_attr(l_get_info.record_id).incumbant_ssn := l_val||l_get_info.seq_num;
    ELSE
     l_attr(l_get_info.record_id).incumbant_ssn := l_val1||l_get_info.seq_num;
    END IF;
   END IF;
  END LOOP;
  CLOSE c_get_info_mast;
  l_count:=l_attr.first;
  IF l_count > 0 THEN
   WHILE  l_count <= l_attr.last
   LOOP
    populate_pos_error_tab (p_request_id        =>p_request_id
                    ,p_record_id         =>l_count
                    ,p_position_id       =>NULL
                    ,p_business_group_id =>p_business_group_id
                    ,p_status            =>NVL(l_attr(l_count).status,'NULL')
                    ,p_indicator         =>NVL(l_attr(l_count).indicator,'NULL')
                    ,p_function_code     =>NVL(l_attr(l_count).function_code,'NULL')
                    ,p_department_code   =>NVL(l_attr(l_count).department_code,'NULL')
                    ,p_agency_code       =>NVL(l_attr(l_count).agency_code,'NULL')
                    ,p_poi               =>NVL(l_attr(l_count).poi,'NULL')
                    ,p_mrn               =>NVL(l_attr(l_count).mrn,'NULL')
                    ,p_grade             =>NVL(l_attr(l_count).grade,'NULL')
                    ,p_pos_num           =>NVL(l_attr(l_count).pos_num,'NULL')
                    ,p_incumbant_ssn     =>NVL(l_attr(l_count).incumbant_ssn,'NULL')
                    ,p_oblig_ssn         =>NULL
                     );

   l_count :=l_attr.next(l_count);
   END LOOP;
  END IF;
 ELSE
  DELETE FROM  ghr_pa_interface_err_dtls;
  OPEN c_get_pa_info;
  LOOP
   FETCH c_get_pa_info INTO l_get_pa_info;
   EXIT WHEN c_get_pa_info%NOTFOUND;
   IF l_temp_rcd_id <> l_get_pa_info.record_id THEN
    l_temp_rcd_id := l_get_pa_info.record_id;
   END IF;
   IF l_get_pa_info.string_val='S' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).status := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).status := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='RPA_SSN' OR l_get_pa_info.string_val= 'REM_SSN'
     OR l_get_pa_info.string_val= 'ADD_SSN' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).ssno := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).ssno := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='RPA_NFC_AGENCY' OR l_get_pa_info.string_val= 'REM_AGNCY_CD'
     OR l_get_pa_info.string_val= 'ADD_AGNCY_CD' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).agency_code := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).agency_code := l_val1||l_get_pa_info.seq_num;
    END IF;

   ELSIF l_get_pa_info.string_val='RPA_PMSO_DEPT' OR l_get_pa_info.string_val= 'REM_DEPT_CD' OR
    l_get_pa_info.string_val= 'ADD_DEPT_CODE' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).department_code := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).department_code := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val= 'RPA_POI' OR l_get_pa_info.string_val= 'REM_POI'
      OR l_get_pa_info.string_val= 'ADD_POI'  THEN

    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).poi := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).poi := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='063' OR l_get_pa_info.string_val='110'
        OR l_get_pa_info.string_val='347' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).indicator  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).indicator  := l_val1||l_get_pa_info.seq_num;
    END IF;

   ELSIF l_get_pa_info.string_val='RPA_PAY_PERIOD_NUM' OR l_get_pa_info.string_val= 'REM_PAY_PER_NUM'
      OR l_get_pa_info.string_val= 'ADD_PAY_PER_NUM' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).pay_per_num  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).pay_per_num  := l_val1||l_get_pa_info.seq_num;
    END IF;

   ELSIF l_get_pa_info.string_val='RPA_AUTH_DT' OR l_get_pa_info.string_val= 'AWD_AUTH_DT'  THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).auth_dt  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).auth_dt  := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='RPA_FIRST_NOA_CD'
      OR l_get_pa_info.string_val= 'AWD_NAT_ACT_POS1' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).noa1  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).noa1  := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='RPA_SEC_NOA_CD' OR l_get_pa_info.string_val='AWD_NAT_ACT_POS2' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).noa2  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).noa2  := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='RPA_EFF_DATE' OR l_get_pa_info.string_val='AWD_PERS_EFF_DT'
    OR l_get_pa_info.string_val='ADD_EFF_DATE' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).eff_dt  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).eff_dt  := l_val1||l_get_pa_info.seq_num;
    END IF;
   ELSIF l_get_pa_info.string_val='6700' THEN
    IF l_get_pa_info.seq_num >9 THEN
     l_attr_pa(l_get_pa_info.record_id).doc_typ  := l_val||l_get_pa_info.seq_num;
    ELSE
     l_attr_pa(l_get_pa_info.record_id).doc_typ  := l_val1||l_get_pa_info.seq_num;
    END IF;
   END IF;
  END LOOP;
  CLOSE c_get_pa_info;
  l_count:=l_attr_pa.first;
  l_count1:=l_attr_pa.count;
  IF l_count > 0 THEN
   WHILE  l_count <= l_attr_pa.last
   LOOP
   populate_pa_error_tab (p_request_id          =>p_request_id
                             ,p_record_id         =>l_count
                             ,p_person_id         =>NULL
                             ,p_business_group_id =>p_business_group_id
                             ,p_status            =>NVL(l_attr_pa(l_count).status,'NULL')
                             ,p_indicator         =>NVL(l_attr_pa(l_count).indicator,'NULL')
                             ,p_department_code   =>NVL(l_attr_pa(l_count).department_code,'NULL')
                             ,p_agency_code       =>NVL(l_attr_pa(l_count).agency_code,'NULL')
                             ,p_poi               =>NVL(l_attr_pa(l_count).poi,'NULL')
                             ,p_ssn               =>NVL(l_attr_pa(l_count).ssno,'NULL')
                             ,p_pay_per_num       =>NVL(l_attr_pa(l_count).pay_per_num,'NULL')
                             ,p_auth_dt           =>NVL(l_attr_pa(l_count).auth_dt,'NULL')
                             ,p_noa1              =>NVL(l_attr_pa(l_count).noa1,'NULL')
                             ,p_noa2              =>NVL(l_attr_pa(l_count).noa2,'NULL')
                             ,p_eff_dt            =>NVL(l_attr_pa(l_count).eff_dt,'NULL')
                             ,p_doc_typ           =>NVL(l_attr_pa(l_count).doc_typ,'NULL')
                             );
   l_count :=l_attr_pa.next(l_count);
   END LOOP;
  END IF;
 END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;



---============================================================================
--PROCEDURE CHK_SAME_DAY_ACT_sun
--This procedure checks for the original action and correction occured
--on the same day.
--When the original action is corrected, the report should have only one row
--with original action but having the corrected value.
--If the original action is cancelled, then both the rows are not sent.
---===========================================================================
PROCEDURE CHK_SAME_DAY_ACT (p_request_id  IN NUMBER
                           ,p_rslt_id     IN NUMBER
                           )
IS

CURSOR c_chk_dup_action (cp_request_id NUMBER
                         ,cp_rslt_id     NUMBER
                         )
IS
SELECT berd.*
  FROM  ben_ext_rslt_dtl berd
 WHERE berd.request_id  =cp_request_id
   AND berd.ext_rslt_id =cp_rslt_id
   AND ( (berd.val_03   ='063'
   AND berd.val_29      IN ('001','002')
		)
    OR (berd.val_03     ='110'
   AND berd.val_38      IN ('001','002')
		)
   )
   ORDER BY berd.person_id, TO_DATE(berd.val_34,'MMDDYYYY') desc, to_number(berd.val_01) desc ; -- Bug 4923152

 CURSOR c_berd_values(cp_request_id NUMBER,
					  cp_rslt_id NUMBER,
					  cp_val_01 VARCHAR2) IS
  SELECT berd.*
	FROM  ben_ext_rslt_dtl berd
	WHERE berd.request_id  =cp_request_id
	AND berd.ext_rslt_id =cp_rslt_id
	AND berd.val_01 = cp_val_01;

 CURSOR c_rpa_values(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
 SELECT par.*
	FROM ghr_pa_requests par
	WHERE pa_request_id = c_pa_request_id;

 CURSOR c_rpa_for_person(c_person_id ghr_pa_requests.person_id%type,
						 c_canc_rpa_id ghr_pa_requests.pa_request_id%type,
						 c_approval_date ghr_pa_requests.approval_date%type)
	IS
	SELECT pa_request_id
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_cancel_or_correct = 'CANCEL'
	AND pa_request_id < c_canc_rpa_id
	AND TRUNC(approval_date) = c_approval_date;

 CURSOR c_child_rpas(c_pa_request_id  ghr_pa_requests.pa_request_id%type) IS
 SELECT pa_request_id
	FROM ghr_pa_requests
	WHERE pa_notification_id IS NOT NULL
	START WITH pa_request_id = c_pa_request_id
	CONNECT BY PRIOR pa_request_id = altered_pa_request_id; -- Bug 4923152

 CURSOR c_child_rpas_correct(c_pa_request_id  ghr_pa_requests.pa_request_id%type) IS
 SELECT pa_request_id
	FROM ghr_pa_requests
	WHERE pa_notification_id IS NOT NULL
	START WITH pa_request_id = c_pa_request_id
	CONNECT BY PRIOR altered_pa_request_id = pa_request_id; -- Bug 4923152

TYPE t_del_rec IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
l_del_rec t_del_rec;
l_del_corr_rec t_del_rec;
l_orig_pa ghr_pa_requests%rowtype;
l_canc_pa ghr_pa_requests%rowtype;
l_orig_pa_request_id ghr_pa_requests.pa_request_id%type;
l_canc_pa_request_id ghr_pa_requests.pa_request_id%type;
l_first_noa_code ghr_pa_requests.first_noa_code%type;
l_second_noa_code ghr_pa_requests.second_noa_code%type;
l_person_id ghr_pa_requests.person_id%type;
l_berd_original ben_ext_rslt_dtl%rowtype;
l_berd_corrected ben_ext_rslt_dtl%rowtype;
TYPE t_correct_records IS TABLE OF ben_ext_rslt_dtl%rowtype INDEX BY PLS_INTEGER;
l_correct_records t_correct_records;
l_result NUMBER;
TYPE t_skip_records IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
l_skip_records t_skip_records;
l_skip_this BOOLEAN;
l_skip_person_id ghr_pa_requests.person_id%type;
l_effective_date ghr_pa_requests.effective_date%type;

PROCEDURE debug_prg(txt varchar2) IS
BEGIN
	hr_utility.set_location(txt,120);
END debug_prg;

BEGIN
-- Loop through Cancellation and Correction actions.

l_skip_person_id := -1;
l_skip_records.delete;
l_skip_this := FALSE;
--delete from sun_temp;

debug_prg('Before for loop');

FOR l_chk_dup_action IN c_chk_dup_action(p_request_id,p_rslt_id) LOOP
	-- If Cancellation action, check if original action was created on the same date
	-- If yes and also if extract date is greater than approval date, delete both actions.

		-- Initialise Values to NULL
		l_orig_pa := NULL;
		l_canc_pa := NULL;
		l_first_noa_code := NULL;
		l_second_noa_code := NULL;
		l_orig_pa_request_id := NULL;
		l_canc_pa_request_id := NULL;
		l_person_id := NULL;
		l_berd_original := NULL;
		l_berd_corrected := NULL;
		-- For Personnel actions other than Award
		IF l_chk_dup_action.val_03 ='063' THEN
			debug_prg('Before assigning values');
			-- Assign values
			l_first_noa_code := l_chk_dup_action.val_29;
			l_second_noa_code := l_chk_dup_action.val_30;
			l_effective_date := TO_DATE(l_chk_dup_action.val_34,'MMDDYYYY');
			l_orig_pa_request_id := TO_NUMBER(l_chk_dup_action.val_150);
			l_canc_pa_request_id := TO_NUMBER(l_chk_dup_action.val_01);
			l_person_id := l_chk_dup_action.person_id;
			debug_prg('Current RPA ID: ' || l_canc_pa_request_id);
		ELSIF l_chk_dup_action.val_03 ='110' THEN
			-- Assign values
			l_first_noa_code := l_chk_dup_action.val_30;
			l_second_noa_code := l_chk_dup_action.val_39;
			l_effective_date := TO_DATE(l_chk_dup_action.val_33,'MMDDYYYY');
			l_orig_pa_request_id := TO_NUMBER(l_chk_dup_action.val_55);
			l_canc_pa_request_id := TO_NUMBER(l_chk_dup_action.val_01);
			l_person_id := l_chk_dup_action.person_id;
--			l_approval_date := l_chk_dup_action.val_57;
			debug_prg('Current RPA ID: ' || l_canc_pa_request_id);
		END IF; -- IF l_chk_dup_action.val_03 ='063' THEN

		debug_prg('l_person_id: ' || l_person_id);
		debug_prg('l_skip_person_id: ' || l_skip_person_id);

		IF l_person_id = l_skip_person_id THEN
			-- Ignore records already added to the list
			IF l_skip_records.COUNT > 0 THEN
				FOR l_already_del IN l_skip_records.FIRST .. l_skip_records.LAST LOOP
					debug_prg('In Collection ' || l_skip_records(l_already_del));
					debug_prg('Corr RPA ID ' || l_canc_pa_request_id);
					IF l_canc_pa_request_id = l_skip_records(l_already_del) THEN
						l_skip_this := TRUE;
						EXIT;
					END IF;
					l_skip_this := FALSE;
				END LOOP;
			END IF;
		ELSE
			l_skip_records.DELETE;
		END IF; -- 	IF l_person_id = l_skip_person_id
        debug_prg('Before l_skip_this = FALSE ');

		IF l_skip_this = FALSE THEN
			FOR l_orig_values IN c_rpa_values(l_orig_pa_request_id) LOOP
				l_orig_pa := l_orig_values;
			END LOOP;

			FOR l_canc_values IN c_rpa_values(l_canc_pa_request_id) LOOP
				l_canc_pa := l_canc_values;
			END LOOP;

			IF l_first_noa_code = '001' THEN
				debug_prg('Before comparing dates');
				-- If Actions done on the same date, add them to delete record.
--				IF ghr_us_nfc_extracts.g_ext_start_dt >= TRUNC(l_orig_pa.approval_date) AND
				IF (
					(TRUNC(l_orig_pa.approval_date)
					BETWEEN TRUNC(ghr_us_nfc_extracts.g_ext_start_dt) AND TRUNC(NVL(ghr_us_nfc_extracts.g_ext_end_dt,ghr_us_nfc_extracts.g_ext_start_dt))
					)
					OR
					(TRUNC(l_orig_pa.effective_date)
					BETWEEN TRUNC(ghr_us_nfc_extracts.g_ext_start_dt) AND TRUNC(NVL(ghr_us_nfc_extracts.g_ext_end_dt,ghr_us_nfc_extracts.g_ext_start_dt))
					)
					)
				AND	TRUNC(l_orig_pa.approval_date) = TRUNC(l_canc_pa.approval_date) THEN
					-- If it's Appointment action, delete all old actions done between appt and cancellation.
					debug_prg('IF l_second_noa_code = 100');
					IF l_second_noa_code = '100' THEN
						l_del_rec(l_del_rec.count+1) := l_canc_pa_request_id;
						FOR l_canc_appt IN c_rpa_for_person(l_person_id,l_canc_pa_request_id, TRUNC(l_canc_pa.approval_date)) LOOP
							l_del_rec(l_del_rec.count+1) := l_canc_appt.pa_request_id;
							l_skip_records(l_skip_records.count+1) := l_canc_appt.pa_request_id;
						END LOOP;
					ELSE
						--l_del_rec(l_del_rec.count+1) := l_orig_pa_request_id;
						-- Delete child records(canc/corr) too
						FOR l_child_rpas IN c_child_rpas(l_orig_pa_request_id) LOOP
							l_del_rec(l_del_rec.count+1) := l_child_rpas.pa_request_id;
							debug_prg('Recs to be deleted1: ' || l_child_rpas.pa_request_id);
							l_skip_records(l_skip_records.count+1) := l_child_rpas.pa_request_id;
						END LOOP;
					END IF; -- IF l_second_noa_code = '100' THEN
					l_skip_person_id := l_person_id;
				END IF; -- IF ghr_us_nfc_extracts.g_ext_star
			-- Correction action goes here...
			ELSIF l_first_noa_code = '002' THEN
				----------
				-- Berd corrected
				l_berd_corrected := l_chk_dup_action;
				-- Change sysdate after testing.
				IF (
					(TRUNC(l_orig_pa.approval_date)
					BETWEEN TRUNC(ghr_us_nfc_extracts.g_ext_start_dt) AND TRUNC(NVL(ghr_us_nfc_extracts.g_ext_end_dt,ghr_us_nfc_extracts.g_ext_start_dt))
					)
					OR
					(TRUNC(l_orig_pa.effective_date)
					BETWEEN TRUNC(ghr_us_nfc_extracts.g_ext_start_dt) AND TRUNC(NVL(ghr_us_nfc_extracts.g_ext_end_dt,ghr_us_nfc_extracts.g_ext_start_dt))
					)
					)
				AND	TRUNC(l_orig_pa.approval_date) = TRUNC(l_canc_pa.approval_date) THEN
							--l_del_rec(l_del_corr_rec.count+1) := l_orig_pa_request_id;
						-- Delete child records(canc/corr) too

						FOR l_child_rpas IN c_child_rpas_correct(l_canc_pa_request_id) LOOP
							l_del_rec(l_del_rec.count+1) := l_child_rpas.pa_request_id;
							debug_prg('Recs to be deleted2: ' || l_child_rpas.pa_request_id);
							l_skip_records(l_skip_records.count+1) := l_child_rpas.pa_request_id;
							l_orig_pa_request_id := l_child_rpas.pa_request_id;
						END LOOP;


						-- Berd Original
						FOR l_berd_org IN c_berd_values(p_request_id,p_rslt_id,l_orig_pa_request_id) LOOP
							l_berd_original := l_berd_org;
						END LOOP;

						debug_prg('Before update: ' || l_berd_corrected.val_29);
						upd_Rslt_Dtl(l_berd_corrected,l_berd_original);
						debug_prg('After update: ' || l_berd_corrected.val_29);
						l_correct_records(l_correct_records.count+1)  := l_berd_corrected;
						l_skip_person_id := l_person_id;
				END IF; -- IF ... >= TRUNC(l_orig_pa.approval_date)

			END IF; -- IF l_first_noa_code = '001' THEN
		END IF; -- IF l_skip_this = FALSE THE

END LOOP; -- FOR l_chk_dup_action IN (

-- For deletion
IF l_del_rec.COUNT > 0 THEN

	FOR l_recs IN l_del_rec.FIRST..l_del_rec.LAST LOOP
	   debug_prg('RPA Id: ' || l_del_rec(l_recs));
		-- Deletion code here
		DELETE
			FROM ben_ext_rslt_dtl berd
			WHERE berd.request_id= p_request_id
			AND berd.ext_rslt_id = p_rslt_id
			AND val_01 = TO_CHAR(l_del_rec(l_recs));
		-- -- Bug 4937846
		DELETE
			FROM ghr_pa_interface_err_dtls perr
			WHERE perr.ext_request_id= p_request_id
			AND perr.result_id = p_rslt_id
			AND pa_request_id = l_del_rec(l_recs);

	END LOOP;

END IF;

-- For updation of records.
IF l_correct_records.COUNT > 0 THEN
	FOR l_ins_recs IN l_correct_records.FIRST .. l_correct_records.LAST LOOP
		debug_prg('RPA Id: ' || l_correct_records(l_ins_recs).val_01);
		Ins_Rslt_Dtl(l_correct_records(l_ins_recs),l_result);
		debug_prg('ins result: ' || l_result);
	END LOOP;
END IF;

EXCEPTION
WHEN OTHERS THEN
	debug_prg('Sql code' || sqlcode || ' : ' || sqlerrm);
	RAISE;
END CHK_SAME_DAY_ACT;

END ghr_nfc_error_proc;

/
