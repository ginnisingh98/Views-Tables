--------------------------------------------------------
--  DDL for Package ASG_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_CUSTOM_PUB" AUTHID CURRENT_USER as
/* $Header: asgpcsts.pls 120.1 2005/08/12 02:50:39 saradhak noship $ */


  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ASG_CUSTOM_PUB';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'asgpcstb.pls';
  G_INS                      CONSTANT CHAR    := 'I';
  G_UPD                      CONSTANT CHAR    := 'U';
  G_DEL                      CONSTANT CHAR    := 'D';
  G_ALL_USERS                CONSTANT NUMBER  := -999999;


  PROCEDURE customize_pub_item(
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item_name              IN VARCHAR2,
   p_base_table_name           IN VARCHAR2,
   p_primary_key_columns        IN VARCHAR2,
   p_data_columns               IN VARCHAR2,
   p_additional_filter          IN VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_error_message              OUT NOCOPY VARCHAR2
                              );

  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dmlList                    IN asg_download.dml_list,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
                        );

  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dml_type                   IN CHAR,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
	   	     );

  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessid                   IN NUMBER,
   p_userid                     IN NUMBER,
   p_dml                        IN CHAR,
   p_timestamp                  IN DATE,
   x_return_status              OUT NOCOPY VARCHAR2
		     );

  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessid                   IN NUMBER,
   p_userid                     IN NUMBER,
   p_dml                        IN CHAR,
   p_timestamp                  IN DATE,
   p_pkvalues                   IN asg_download.pk_list,
   x_return_status              OUT NOCOPY VARCHAR2
		     );

  PROCEDURE mark_dirty (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item                   IN VARCHAR2,
   p_accessList                 IN asg_download.access_list,
   p_userid_list                IN asg_download.user_list,
   p_dml_type                   IN CHAR,
   p_timestamp                  IN DATE,
   p_bulk_flag                  IN BOOLEAN,
   x_return_status              OUT NOCOPY VARCHAR2
		     );

END ASG_CUSTOM_PUB;

 

/
