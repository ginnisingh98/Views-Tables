--------------------------------------------------------
--  DDL for Package OKC_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PARAMETERS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPPRMS.pls 120.2 2006/02/28 14:46:41 smallya noship $ */

  subtype prmv_rec_type is OKC_PRM_PVT.prmv_rec_type;

  TYPE prmv_tbl_type IS TABLE OF prmv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE name_value_rec_type IS RECORD (
   NAME                            VARCHAR2(100),
   VALUE                           VARCHAR2(2000));

  TYPE name_value_tbl_type IS TABLE OF name_value_rec_type
        INDEX BY BINARY_INTEGER;

  PROCEDURE add_language;

  procedure create_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type,
                              x_prmv_rec	OUT NOCOPY	prmv_rec_type);
  procedure create_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type,
                              x_prmv_tbl	OUT NOCOPY	prmv_tbl_type);

  procedure update_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type,
                              x_prmv_rec	OUT NOCOPY	prmv_rec_type);
  procedure update_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type,
                              x_prmv_tbl	OUT NOCOPY	prmv_tbl_type);

  procedure delete_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type);
  procedure delete_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type);

  procedure lock_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type);
  procedure lock_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type);

-- for lct only
  procedure set_sql_id (p_sql_id number);
  function get_sql_id return number;

-- for process api only
  function Count_Params RETURN NUMBER;
  procedure Set_Params(p_array in JTF_VARCHAR2_TABLE_2000);
  function Get_Name(p_index in number) return varchar2;
  function Get_Value(p_index in number) return varchar2;
  function Get(p_name in varchar2) return varchar2;

  function Get_Index(p_name in varchar2) return number;
  procedure Reset_Param(p_index in number, p_value in varchar2);

END OKC_PARAMETERS_PUB;

 

/
