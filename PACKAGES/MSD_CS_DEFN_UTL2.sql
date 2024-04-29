--------------------------------------------------------
--  DDL for Package MSD_CS_DEFN_UTL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_DEFN_UTL2" AUTHID CURRENT_USER as
/* $Header: msdcsu2s.pls 115.7 2003/11/04 18:39:21 dkang ship $ */

    Type G_TYPE_DEFN_PARA_REC is
        RECORD ( PARA_NAME                  MSD_CS_DEFINITIONS.name%TYPE,
                 PARA_TYPE                  MSD_CS_DEFINITIONS.CS_TYPE%TYPE,
                 VS_NAME                    varchar2(240),
                 SQL_STMT                   varchar2(2000),
                 MULTI_INPUT_FLAG           varchar2(30),
                 MESSAGE                    varchar2(2000),
                 DEFAULT_VAL                varchar2(240),
                 DEFAULT_CODE               varchar2(30));


    Type G_TYPE_DEFN_PARA_REC_LIST is TABLE of G_TYPE_DEFN_PARA_REC ;


    Procedure build_para_list (
        p_instance        in number,
        p_coll_cond       in varchar2,
        p_pull_cond       in varchar2);

    Procedure build_para_list (
        p_instance        in number,
        p_coll_cond       in varchar2,
        p_pull_cond       in varchar2,
        p_defn_para_list in out NOCOPY g_type_defn_para_rec_list);

    Procedure build_gen_para_list ( p_instance in number,
                                    p_cond in     varchar2,
                                    p_defn_para_list in out NOCOPY g_type_defn_para_rec_list);

    Function counts return number;

    Procedure get_rec (
        p_index         in  number,
        p_message       in out NOCOPY varchar2,
        p_type          in out NOCOPY varchar2,
        p_sql_stmt      IN OUT NOCOPY varchar2,
        p_multi_flag    in out nocopy varchar2,
        p_default_code  in out nocopy varchar2,
        p_default_val   in out nocopy varchar2);


    Function get_char_property( p_cond varchar2,
                            p_start_pos number,
                            p_end_pos   number,
                            p_index number) return varchar2;

    Function genereate_sql_from_vs( p_vs_name  IN varchar2,
                                    p_dblink   IN varchar2,
                                    p_val_col  IN OUT nocopy varchar2,
                                    p_id_col   IN OUT nocopy varchar2) return varchar2;

    Function get_default_value (p_val_col   IN varchar2,
                                p_id_col    IN varchar2,
                                p_sql_stmt  IN varchar2,
                                p_default_code IN varchar2) return varchar2;


End;

 

/
