--------------------------------------------------------
--  DDL for Package MSD_CS_DFN_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_DFN_UTL" AUTHID CURRENT_USER as
/* $Header: msdcsuts.pls 115.11 2003/09/10 18:08:15 dkang ship $ */
    --
    Type G_TYP_CS_DEFN_CLMN_MAP is
        RECORD ( source_view_column_name    msd_cs_defn_column_dtls_v.source_view_column_name%TYPE,
/*                 planning_view_column_name  msd_cs_defn_column_dtls_v.planning_view_column_name%TYPE, */
                 column_identifier          msd_cs_defn_column_dtls_v.column_identifier%TYPE,
                 table_column               msd_cs_defn_column_dtls_v.table_column%type,
/*                 alt_key_flag               msd_cs_defn_column_dtls_v.alt_key_flag%type,
                 data_type                  msd_cs_defn_column_dtls_v.data_type%type,
*/
                 index_cntr                 number);

    Type G_TYP_CS_DEFN_CLMN_MAP_LIST is TABLE of G_TYP_CS_DEFN_CLMN_MAP;

    Type G_TYP_ARRAY_VARCHAR is VARRAY(255) of msd_cs_data.attribute_1%type;

    Type G_TYP_SOURCE_STREAM is RECORD (
        pk_id                   number,
        instance                Varchar2(255),
        prd_level_id            Varchar2(255),
        prd_sr_level_value_pk   Varchar2(255),
        prd_level_value         Varchar2(255),
        prd_level_value_pk      Varchar2(255),
        geo_level_id            Varchar2(255),
        geo_sr_level_value_pk   Varchar2(255),
        geo_level_value         Varchar2(255),
        geo_level_value_pk      Varchar2(255),
        org_level_id            Varchar2(255),
        org_sr_level_value_pk   Varchar2(255),
        org_level_value         Varchar2(255),
        org_level_value_pk      Varchar2(255),
        prd_parent_level_id            Varchar2(255),
        prd_parent_sr_level_value_pk   Varchar2(255),
        prd_parent_level_value         Varchar2(255),
        prd_parent_level_value_pk      Varchar2(255),
        rep_level_id            Varchar2(255),
        rep_sr_level_value_pk   Varchar2(255),
        rep_level_value         Varchar2(255),
        rep_level_value_pk      Varchar2(255),
        chn_level_id            Varchar2(255),
        chn_sr_level_value_pk   Varchar2(255),
        chn_level_value         Varchar2(255),
        chn_level_value_pk      Varchar2(255),
        ud1_level_id            Varchar2(255),
        ud1_sr_level_value_pk   Varchar2(255),
        ud1_level_value         Varchar2(255),
        ud1_level_value_pk      Varchar2(255),
        ud2_level_id            Varchar2(255),
        ud2_sr_level_value_pk   Varchar2(255),
        ud2_level_value         Varchar2(255),
        ud2_level_value_pk      Varchar2(255),
        tim_level_id      Varchar2(255),
        attribute_35      Varchar2(255),
        attribute_36      Varchar2(255),
        attribute_37      Varchar2(255),
        attribute_38      Varchar2(255),
        attribute_39      Varchar2(255),
        attribute_40      Varchar2(255),
        attribute_41      Varchar2(255),
        attribute_42      Varchar2(255),
        attribute_43      Varchar2(255),
        attribute_44      Varchar2(255),
        attribute_45      Varchar2(255),
        attribute_46      Varchar2(255),
        attribute_47      Varchar2(255),
        attribute_48      Varchar2(255),
        attribute_49      Varchar2(255),
        dcs_level_id            Varchar2(255),
        dcs_sr_level_value_pk   Varchar2(255),
        dcs_level_value         Varchar2(255),
        dcs_level_value_pk      Varchar2(255),
        attribute_54      Varchar2(255),
        attribute_55      Varchar2(255),
        attribute_56      Varchar2(255),
        attribute_57      Varchar2(255),
        attribute_58      Varchar2(255),
        attribute_59      Varchar2(255),
        attribute_60      Varchar2(255),
        designator        Varchar2(255));

    /*  Constants */
    C_PRD_LEVEL_ID  number:=1;
    C_ORG_LEVEL_ID  number:=2;
    C_GEO_LEVEL_ID  number:=3;
    C_REP_LEVEL_ID  number:=4;
    C_CHN_LEVEL_ID  number:=5;
    C_PRD_PARENT_LEVEL_ID  number:=6;


    Procedure populate_column_defn_array (p_cs_definition_id in number, p_cs_dfn_clmn_map_list out nocopy G_TYP_CS_DEFN_CLMN_MAP_LIST);

    Procedure conv_cs_rec_to_array(
    p_cs_rec        in out nocopy G_TYP_ARRAY_VARCHAR,
    p_attribute1    in  varchar2,   p_attribute2    in  varchar2,
    p_attribute3    in  varchar2,   p_attribute4    in  varchar2,
    p_attribute5    in  varchar2,   p_attribute6    in  varchar2,
    p_attribute7    in  varchar2,   p_attribute8    in  varchar2,
    p_attribute9    in  varchar2,   p_attribute10   in  varchar2,
    p_attribute11   in  varchar2,   p_attribute12   in  varchar2,
    p_attribute13   in  varchar2,   p_attribute14   in  varchar2,
    p_attribute15   in  varchar2,   p_attribute16   in  varchar2,
    p_attribute17   in  varchar2,   p_attribute18   in  varchar2,
    p_attribute19   in  varchar2,   p_attribute20   in  varchar2,
    p_attribute21   in  varchar2,   p_attribute22   in  varchar2,
    p_attribute23   in  varchar2,   p_attribute24   in  varchar2,
    p_attribute25   in  varchar2,   p_attribute26   in  varchar2,
    p_attribute27   in  varchar2,   p_attribute28   in  varchar2,
    p_attribute29   in  varchar2,   p_attribute30   in  varchar2,
    p_attribute31   in  varchar2,   p_attribute32   in  varchar2,
    p_attribute33   in  varchar2,   p_attribute34   in  varchar2,
    p_attribute35   in  varchar2,   p_attribute36   in  varchar2,
    p_attribute37   in  varchar2,   p_attribute38   in  varchar2,
    p_attribute39   in  varchar2,   p_attribute40   in  varchar2,
    p_attribute41   in  varchar2,   p_attribute42   in  varchar2,
    p_attribute43   in  varchar2,   p_attribute44   in  varchar2,
    p_attribute45   in  varchar2,   p_attribute46   in  varchar2,
    p_attribute47   in  varchar2,   p_attribute48   in  varchar2,
    p_attribute49   in  varchar2,   p_attribute50   in  varchar2,
    p_attribute51   in  varchar2,   p_attribute52   in  varchar2,
    p_attribute53   in  varchar2,   p_attribute54   in  varchar2,
    p_attribute55   in  varchar2,   p_attribute56   in  varchar2,
    p_attribute57   in  varchar2,   p_attribute58   in  varchar2,
    p_attribute59   in  varchar2,   p_attribute60   in  varchar2);

  Function get_dim_desc ( p_dim_code in varchar2) return varchar2;

  Function get_level_id ( p_dim_code in varchar2, p_level_name varchar2) return number;
  Function get_level_name ( p_dim_code in varchar2, p_level_id varchar2) return varchar2;
  Function get_level_desc ( p_dim_code in varchar2, p_level_id varchar2) return varchar2;


  Function get_planning_server_clmn ( p_cs_definition_id in varchar2, p_column_identifier in varchar2) return varchar2;
  PRAGMA RESTRICT_REFERENCES(get_planning_server_clmn, WNDS);


End;

 

/
