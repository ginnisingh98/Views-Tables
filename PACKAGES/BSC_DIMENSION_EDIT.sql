--------------------------------------------------------
--  DDL for Package BSC_DIMENSION_EDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIMENSION_EDIT" AUTHID CURRENT_USER as
/* $Header: BSCEDITS.pls 120.0 2005/06/01 16:27:47 appldev noship $*/

procedure security_sync;
procedure deleteNormalRow(   l_dim_table IN VARCHAR2,
        l_deleted_code IN NUMBER);
procedure deleteMNRow(   l_dim_table IN VARCHAR2,
        l_key_column1 IN VARCHAR2,
        l_key_column2 IN VARCHAR2,
        l_rowid IN VARCHAR2);
procedure markKPI( l_dim_table IN VARCHAR2);

procedure saveNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_code in number, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message  out nocopy varchar2);

procedure saveNormalRowNO(l_dim_table in varchar2, l_code in varchar2,
    l_user_code in varchar2, l_name in varchar2, l_message out nocopy varchar2);

procedure saveMNRow(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number, l_rowid in varchar2,
l_message out nocopy varchar2 );

procedure updateNormalRowNO(l_dim_table in varchar2, l_code in number,
    l_user_code in varchar2, l_name in varchar2,l_message out nocopy varchar2);
procedure insertNormalRowNO(l_dim_table in varchar2,
    l_user_code in varchar2, l_name in varchar2, l_message out nocopy varchar2);
procedure updateNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_code in number, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message out nocopy varchar2);
procedure insertNormalRowNW(l_dim_table in varchar2, l_fk in varchar2,
l_fk_user in varchar2, l_user_code in varchar2,
l_name in varchar2, l_fkcode in number, l_fkusercode in varchar2,
l_message out nocopy varchar2);
FUNCTION  checkrecord(l_dim_table in varchar2, l_user_code in varchar2,
 l_name in varchar2) return boolean;
FUNCTION  checkrecord(l_dim_table in varchar2, l_user_code in varchar2,
 l_name in varchar2, l_code in number) return boolean;
FUNCTION  checkMNrecord(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number) return boolean;
FUNCTION  checkMNrecord(l_dim_table in varchar2,
l_key_column1 in varchar2, l_key_column2 in varchar2,
l_code1 in number,  l_code2 in number,l_rowid in varchar2) return boolean;
function removeComma(l_name varchar2) return varchar2;
FUNCTION Delete_Codes_CascadeMN(
	x_dim_table IN VARCHAR2,
	x_key_column1 IN VARCHAR2,
	x_key_column2 IN VARCHAR2,
	x_deleted_codes1 IN number,
	x_deleted_codes2 IN number
	) RETURN BOOLEAN;
FUNCTION  checkMVnot(l_table in varchar2) return boolean;

procedure saveNormalRowNWM(l_dim_table in varchar2,  l_code in number,
l_user_code in varchar2, l_name in varchar2, l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out nocopy varchar2
);

procedure updateNormalRowNWM(l_dim_table in varchar2, l_code in number,
l_user_code in varchar2, l_name in varchar2,l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out nocopy varchar2
);

procedure insertNormalRowNWM(l_dim_table in varchar2,
l_user_code in varchar2, l_name in varchar2, l_parentcount in number,
l_fklist in BSC_EDIT_VLIST,
l_fkvaluelist in BSC_EDIT_VLIST, l_fkuservaluelist in  BSC_EDIT_VLIST,
l_message out  nocopy varchar2);

FUNCTION  checkUsercodeChange(l_dim_table in varchar2, l_code in number,
l_user_code in varchar2) return boolean;

Function checkChild(l_dim_table in varchar2) return number;

procedure cascadeUsercodeChange(l_dim_table in varchar2,  l_code in number,
l_user_code in varchar2);


procedure checkViewExist(p_view_name varchar2,l_message out nocopy varchar2);

procedure checkMetadata(p_table_name varchar2,p_query varchar2, l_message out nocopy varchar2);

End bsc_dimension_edit;

 

/
