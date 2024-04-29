--------------------------------------------------------
--  DDL for Package Body EGO_GENERIC_TEMP_DML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_GENERIC_TEMP_DML_PVT" AS
/* $Header: EGOVGTDB.pls 120.0.12010000.2 2009/08/05 13:23:41 vijoshi noship $ */

 PROCEDURE Insert_Row ( p_api_version       IN  NUMBER
                       --,p_commit            IN  VARCHAR2 default G_FALSE
                       ,p_generic_temp_tbl  IN  EGO_GENERIC_TEMP_TBL_TYPE
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                      )
 IS

  l_api_name     varchar2(20) := 'Insert_Row';

  l_c_attrib1      EGO_GENERIC_TEMP.C_ATTRIBUTE1%TYPE;
  l_c_attrib2      EGO_GENERIC_TEMP.C_ATTRIBUTE2%TYPE;
  l_n_attrib1      EGO_GENERIC_TEMP.N_ATTRIBUTE1%TYPE;
  l_n_attrib2      EGO_GENERIC_TEMP.N_ATTRIBUTE1%TYPE;
  l_d_attrib1      EGO_GENERIC_TEMP.D_ATTRIBUTE1%TYPE;
  l_d_attrib2      EGO_GENERIC_TEMP.D_ATTRIBUTE1%TYPE;


 BEGIN
   x_return_status   :=  G_RET_STS_SUCCESS;

   for i in p_generic_temp_tbl.first..p_generic_temp_tbl.last
   loop

     l_c_attrib1 := p_generic_temp_tbl(i).C_ATTRIBUTE1;
     l_c_attrib2 := p_generic_temp_tbl(i).C_ATTRIBUTE2;

     l_n_attrib1 := p_generic_temp_tbl(i).N_ATTRIBUTE1;
     l_n_attrib2 := p_generic_temp_tbl(i).N_ATTRIBUTE2;

     l_d_attrib1 := p_generic_temp_tbl(i).D_ATTRIBUTE1;
     l_d_attrib2 := p_generic_temp_tbl(i).D_ATTRIBUTE2;


     INSERT INTO EGO_GENERIC_TEMP (
                 C_ATTRIBUTE1
                ,C_ATTRIBUTE2
                ,N_ATTRIBUTE1
                ,N_ATTRIBUTE2
                ,D_ATTRIBUTE1
                ,D_ATTRIBUTE2
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
                ) VALUES
                (
                 l_c_attrib1
                ,l_c_attrib2
                ,l_n_attrib1
                ,l_n_attrib2
                ,l_d_attrib1
                ,l_d_attrib2
                ,G_CURRENT_USER_ID
                ,sysdate
                ,G_CURRENT_USER_ID
                ,sysdate
                ,G_CURRENT_LOGIN_ID
               );
   end loop;

   --IF p_commit = G_TRUE THEN
--    COMMIT WORK;
   --END IF;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status   :=  G_RET_STS_UNEXP_ERROR;
       x_msg_data       :=  SQLERRM;
       FND_MESSAGE.Set_Name('EGO', 'EGO_INSERT_ERROR');
       FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
       FND_MESSAGE.Set_Token('API_NAME', l_api_name);
       FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
       FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);

 END Insert_Row;
END EGO_GENERIC_TEMP_DML_PVT;

/
