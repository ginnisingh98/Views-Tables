--------------------------------------------------------
--  DDL for Package ASO_SUP_CAPTURE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUP_CAPTURE_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: asospdcs.pls 120.1 2005/06/29 16:04:48 appldev ship $ */

PROCEDURE create_template_instance(
                  p_template_id IN NUMBER,
                  p_owner_table_name IN VARCHAR2,
                  p_owner_table_id IN NUMBER,
                  p_created_by IN NUMBER,
                  p_last_updated_by IN NUMBER,
                  p_last_update_login IN NUMBER,
                  p_commit  IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
			   x_template_instance_id OUT NOCOPY /* file.sql.39 change */  NUMBER,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


PROCEDURE update_data (
                  p_template_instance_id IN NUMBER,
                  p_sect_comp_map_id IN NUMBER,
                  p_created_by IN NUMBER,
                  p_last_updated_by IN NUMBER,
                  p_last_update_login IN NUMBER,
                  p_response_id IN NUMBER,
                  p_response_value IN VARCHAR2,
                  p_multiple_response_flag IN VARCHAR2,
                  p_commit  IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

PROCEDURE delete_data (
                  p_template_instance_id IN NUMBER,
                  p_sect_comp_map_id IN NUMBER,
                  p_commit  IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                  X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                  X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
                  X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


Procedure create_template_instance (
 	               P_VERSION_NUMBER		      IN   NUMBER,
    	            P_INIT_MSG_LIST        	IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    	            P_COMMIT                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    	            P_Template_id           IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
			              P_comp_sect_map_id      IN   JTF_NUMBER_TABLE,
			              P_response_value        IN   JTF_VARCHAR2_TABLE_2000,
			              P_response_id           IN   JTF_NUMBER_TABLE,
			              P_mult_ans_flag         IN   JTF_VARCHAR2_TABLE_100,
			              P_owner_table_name      IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
			              P_owner_table_id        IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
			              X_template_instance_id  OUT NOCOPY /* file.sql.39 change */   NUMBER,
			              X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    	            X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    	            X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

Procedure update_instance_value (
 	               P_VERSION_NUMBER		      IN   NUMBER,
    	            P_INIT_MSG_LIST        	IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    	            P_COMMIT                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
			              P_Template_instance_id  IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
			              P_comp_sect_map_id      IN   JTF_NUMBER_TABLE,
			              P_response_value        IN   JTF_VARCHAR2_TABLE_2000,
			              P_response_id           IN   JTF_NUMBER_TABLE,
			              P_mult_ans_flag         IN   JTF_VARCHAR2_TABLE_100,
			              X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    	            X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */   NUMBER,
    	            X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

END ASO_SUP_CAPTURE_DATA_PKG;

 

/
