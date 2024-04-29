--------------------------------------------------------
--  DDL for Package Body JTF_HA_STATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_HA_STATE_PKG" as
/* $Header: JTFHASB.pls 120.2 2005/11/15 00:48:27 psanyal ship $ */
procedure GET_CURRENT_STATE (
  X_CURRENT_STATE out NOCOPY NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2
) is
  x_perz_data_id NUMBER;
  x_perz_data_name VARCHAR2(120);
  x_perz_data_type VARCHAR2(30);
  x_perz_data_desc VARCHAR2(240);
  x_data_attrib_tbl JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;
  x_status VARCHAR2(1);
  x_msg_count  NUMBER;
  x_msg_data   VARCHAR2(2000);
  l_out_rec JTF_PERZ_DATA_PUB.DATA_ATTRIB_REC_TYPE;
begin
  JTF_PERZ_DATA_PUB.Get_Perz_Data (
        p_api_version_number => 1,
        p_application_id    => 690,
        p_profile_id => null,
        p_perz_data_id => null,
        p_profile_name      => 'JTF_PROPERTY_MANAGER_DEFAULT_1',
        p_perz_data_name  => 'HA.CURRENTSTATE',
        p_perz_data_type  => 'JTF',
        x_perz_data_id => x_perz_data_id,
        x_perz_data_name => x_perz_data_name,
        x_perz_data_type =>  x_perz_data_type,
        x_perz_data_desc => x_perz_data_desc,
        x_data_attrib_tbl => x_data_attrib_tbl,
        x_return_status => x_status,
        x_msg_count => x_msg_count,
        x_msg_data =>  x_msg_data);
   X_RETURN_STATUS := x_status;
   if (X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS) then
	l_out_rec := x_data_attrib_tbl(1);
        X_CURRENT_STATE := to_number(l_out_rec.ATTRIBUTE_VALUE);
   end if;
end GET_CURRENT_STATE;

procedure SET_CURRENT_STATE (
  P_CURRENT_STATE in NUMBER,
  X_RETURN_STATUS out NOCOPY VARCHAR2
) is
  x_perz_data_id NUMBER;
  x_status VARCHAR2(1);
  x_msg_count  NUMBER;
  x_msg_data   VARCHAR2(2000);
  l_data_attrib_tbl JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;
  l_commit VARCHAR2(240);

begin
  l_data_attrib_tbl(1).ATTRIBUTE_NAME := '0';
  l_data_attrib_tbl(1).ATTRIBUTE_TYPE := 'STRING';
  l_data_attrib_tbl(1).ATTRIBUTE_VALUE := to_char(P_CURRENT_STATE);
  l_data_attrib_tbl(1).ATTRIBUTE_CONTEXT := '';
  l_commit := FND_API.G_TRUE;

  JTF_PERZ_DATA_PUB.Save_Perz_Data (
        p_api_version_number => 1,
	p_init_msg_list => FND_API.G_FALSE,
	p_commit => l_commit,
	p_application_id    => 690,
	p_profile_id => null,
	p_profile_name      => 'JTF_PROPERTY_MANAGER_DEFAULT_1',
	p_profile_type => null,
	p_profile_attrib => JTF_PERZ_PROFILE_PUB.G_MISS_PROFILE_ATTRIB_TBL,
	p_perz_data_id => null,
        p_perz_data_name  => 'HA.CURRENTSTATE',
        p_perz_data_type  => 'JTF',
	p_perz_data_desc => null,
        p_data_attrib_tbl => l_data_attrib_tbl,
        x_perz_data_id => x_perz_data_id,
        x_return_status => x_status,
	x_msg_count => x_msg_count,
        x_msg_data =>  x_msg_data);

   X_RETURN_STATUS := x_status;

end SET_CURRENT_STATE;

end JTF_HA_STATE_PKG;

/
