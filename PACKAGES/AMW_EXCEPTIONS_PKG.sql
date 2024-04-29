--------------------------------------------------------
--  DDL for Package AMW_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_EXCEPTIONS_PKG" AUTHID CURRENT_USER as
/*$Header: amwexcps.pls 115.3 2004/03/25 00:37:32 abedajna noship $*/

procedure insert_exception_header_row (
p_Exception_Id		IN Number,
p_Object_Type		IN Varchar2,
p_Old_pk1		IN Varchar2,
p_Old_pk2		IN Varchar2,
p_Old_pk3		IN Varchar2,
p_Old_pk4		IN Varchar2,
p_Old_pk5		IN Varchar2,
p_Old_pk6		IN Varchar2,
p_New_pk1		IN Varchar2,
p_New_pk2		IN Varchar2,
p_New_pk3		IN Varchar2,
p_New_pk4		IN Varchar2,
p_New_pk5		IN Varchar2,
p_New_pk6		IN Varchar2,
p_Transaction_Type	IN Varchar2,
p_Justification	        IN Varchar2,
p_person_party_id	IN Number,
p_existing_ex_id	IN Number,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2);


procedure insert_exceptions_reasons_row (
p_EXCEPTION_ID          in number,
p_REASON_CODE           in varchar2,
p_existing_ex_id	IN Number,
p_commit		in varchar2 := FND_API.G_FALSE,
p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		out nocopy varchar2,
x_msg_count		out nocopy number,
x_msg_data		out nocopy varchar2
);

procedure ADD_LANGUAGE;

end AMW_EXCEPTIONS_PKG;

 

/
