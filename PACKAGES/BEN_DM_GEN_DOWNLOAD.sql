--------------------------------------------------------
--  DDL for Package BEN_DM_GEN_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_GEN_DOWNLOAD" AUTHID CURRENT_USER as
/* $Header: benfdmgndn.pkh 120.0 2006/05/04 04:49:09 nkkrishn noship $ */
-- ------------------------- create_tds_pacakge ------------------------
-- Description:  Create the TDS package and relevant procedures for the table.
-- Input Parameters :
--   p_table_info  - Information about table for which TDS to be generated. Info
--                  like Datetrack, Global Data, Surrogate Primary key etc about
--                  the table is passed as a record type.
--   p_columns_tbl - All the columns of the table stored as a list.
--   p_parameters_tbl - All the columns of the table stored with data type are
--                   stored as a list. e.g p_business_group_id   number
--                   This is used to create the procedure parameter list for
--                   TDS procedure.
--   p_aol_columns_tbl  -  All the columns of the table which have foreign key to
--                    AOL table are stored as a list.
--   p_aol_parameters_tbl - All the columns of the table which have foreign key to
--                    AOL table are stored with data type as a list. This is
--                    used as a parameter list for the procedure generated to
--                    get the  AOL developer key for the given ID value
--                    e.g p_user_id  number
--   p_fk_to_aol_columns_tbl  - It stores the list of all the columns which have
--                   foreign on AOL table and corresponding name of the AOL
--                   table.
-- ------------------------------------------------------------------------
type t_ben_dm_table  is Record
         (TABLE_ID                       NUMBER(15)
         ,TABLE_NAME                    VARCHAR2(30)
         ,UPLOAD_TABLE_NAME             VARCHAR2(30)
         ,TABLE_ALIAS                   VARCHAR2(4)
         ,DATETRACK                     VARCHAR2(1)
         ,DERIVE_SQL                    VARCHAR2(4000)
         ,SURROGATE_PK_COLUMN_NAME      VARCHAR2(30)
         ,SHORT_NAME                    VARCHAR2(23)
         ,LAST_GENERATED_DATE           DATE
         ,GENERATOR_VERSION             VARCHAR2(2000)
         ,SEQUENCE_NAME                 VARCHAR2(30)
         ,LAST_UPDATE_DATE              DATE
         ) ;




function indent
(
 p_indent_spaces  in number default 0,
 p_newline        in varchar2 default 'Y'
) return varchar2 ;



function format_comment
(
 p_comment_text      in  varchar2,
 p_indent_spaces     in  number default 0,
 p_ins_blank_lines   in  varchar2 default 'Y'
) return varchar2 ;



procedure main
(
 --p_business_group_id      in   number,
 --p_person_id              in   number,
 --p_group_order            in   number,
 --p_business_group_name    in   varchar2,
 p_table_alias            in   varchar2,
 p_migration_id           in   number
);

end BEN_DM_GEN_DOWNLOAD;

 

/
