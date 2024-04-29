--------------------------------------------------------
--  DDL for Package IBE_M_IBC_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_M_IBC_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVIBCS.pls 115.0 2002/11/18 23:20:10 jshang noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='IBE_M_IBC_INT_PVT';
g_api_version CONSTANT NUMBER := 1.0;

FUNCTION getTransLang(p_citem_version_id IN NUMBER,
				  p_base_language IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION getLang(p_citem_version_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION getLiveStatus(p_citem_id IN NUMBER, p_citem_version_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION getLiveVersion(p_citem_id IN NUMBER)
RETURN NUMBER;

FUNCTION getStore(p_citem_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION getAvalVersion(p_citem_id IN NUMBER)
RETURN NUMBER;

FUNCTION getAvalVersionId(p_citem_id IN NUMBER)
RETURN NUMBER;


PRAGMA RESTRICT_REFERENCES(getTransLang, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getLang, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getLiveStatus, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getLiveVersion, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getStore, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getAvalVersion, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(getAvalVersionId, WNDS, WNPS);

PROCEDURE Batch_Update_Labels(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_content_item_id_tbl IN JTF_NUMBER_TABLE,
  p_version_number_tbl IN JTF_NUMBER_TABLE,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Update_Label_Association(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_old_content_item_id IN NUMBER DEFAULT NULL,
  p_old_version_number IN NUMBER DEFAULT NULL,
  p_new_content_item_id IN NUMBER,
  p_new_version_number IN NUMBER,
  p_media_object_id IN NUMBER DEFAULT NULL,
  p_association_type_code IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Delete_Label_Association(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_content_item_id IN NUMBER,
  p_version_number IN NUMBER,
  p_media_object_id IN NUMBER,
  p_association_type_code IN VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Get_Object_Name(
  p_association_type_code IN VARCHAR2,
  p_associated_object_val1 IN VARCHAR2,
  p_associated_object_val2 IN VARCHAR2,
  p_associated_object_val3 IN VARCHAR2,
  p_associated_object_val4 IN VARCHAR2,
  p_associated_object_val5 IN VARCHAR2,
  x_object_name OUT NOCOPY VARCHAR2,
  x_object_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2);
END IBE_M_IBC_INT_PVT;

 

/
