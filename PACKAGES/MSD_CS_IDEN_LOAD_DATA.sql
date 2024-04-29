--------------------------------------------------------
--  DDL for Package MSD_CS_IDEN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_IDEN_LOAD_DATA" AUTHID CURRENT_USER as
/* $Header: msdcsids.pls 115.5 2002/05/09 12:39:19 pkm ship      $ */

    Procedure load_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       );
    Procedure Insert_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       );

    Procedure Update_row (
        p_column_identifier       in  varchar2,
	p_system_flag		  in  varchar2,
        p_description             in  varchar2,
        p_identifier_type         in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       );
    Procedure translate_row (
        p_column_identifier       in  varchar2,
        p_description             in  varchar2,
        p_user_prompt             in  varchar2,
        p_owner                   in  varchar2
       );
    Procedure ADD_LANGUAGE;

End;

 

/
