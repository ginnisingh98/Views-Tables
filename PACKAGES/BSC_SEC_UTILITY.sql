--------------------------------------------------------
--  DDL for Package BSC_SEC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SEC_UTILITY" AUTHID CURRENT_USER AS
/*$Header: BSCSECUS.pls 120.0 2005/06/01 15:58:53 appldev noship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.3=120.0):~PROD:~PATH:~FILE
 function get_item_value(p_level_view_name varchar2,p_level_value varchar2) return varchar2;
 function get_lowest_dim_ind(p_tab_id varchar2,p_resp_id varchar2) return number;
 function get_parent_value(p_tab_id  number,p_level_index number,p_level_value varchar2) return varchar2;

 procedure Update_tab_access (
 P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;


procedure Update_list_access (
 P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_DIM_LEVEL_INDEX	in number,
 P_DIM_LEVEL_VALUE	in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure insert_tab_access (
 P_RESP_ID		in number,
 P_TAB_ID		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure insert_kpi_access (
 P_RESP_ID		in number,
 P_INDICATOR		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

 procedure Update_kpi_access (
 P_ROWID		in ROWID       := null,
 P_RESP_ID		in number,
 P_INDICATOR		in number,
 P_START_DATE	in date,
 P_END_DATE	    in date,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

procedure remove_kpi_access(
p_resp_id in number,
p_indicator in number,
p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
x_return_status        OUT NOCOPY  VARCHAR2,
x_errorcode            OUT NOCOPY  NUMBER,
x_msg_count            OUT NOCOPY  NUMBER,
x_msg_data             OUT NOCOPY  VARCHAR2
) ;


END bsc_sec_utility;

 

/
