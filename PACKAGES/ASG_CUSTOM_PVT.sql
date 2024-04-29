--------------------------------------------------------
--  DDL for Package ASG_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_CUSTOM_PVT" AUTHID CURRENT_USER as
/* $Header: asgvcsts.pls 120.1 2005/08/12 02:59:33 saradhak noship $ */



--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ASG_CUSTOM_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'asgvcstb.pls';


  -- This procedure is used to redefine custom publication items
  -- by speciying the base table and other parameters.
  --   p_pub_item_name specifies the name of custom publication item
  --   p_base_table_name parameter can be a view as well.
  --   p_primary_key_columns is comma separated list of columns that
  --   constitute the primary key.
  --   p_data_columns is comma separated list of columns that should
  --   be in the publication item are not part of primary key columns
  --   p_additional_filter is additional predicate on PIV besides
  --   the ones already defined.
  --   x_error_status return FND_API.G_RET_STS_SUCCESS when the
  --   procedure executed without error.
  --   x_error_message contains a descriptive message if the x_error_status

  --   is not FND_API.G_RET_STS_SUCCESS
  PROCEDURE customize_pub_item(
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item_name              IN VARCHAR2,
   p_base_table_name            IN VARCHAR2,
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

FUNCTION exec_cmd(pCmd in varchar2) RETURN VARCHAR2;
FUNCTION  generate_where (collist in varchar2) RETURN VARCHAR2;
FUNCTION  generate_query (collist in varchar2, cnt in number) RETURN VARCHAR2;
FUNCTION find_num_pkcols (pkcolumns in varchar2) RETURN number;
PROCEDURE log (p_mesg VARCHAR2);
FUNCTION get_col (col varchar2) RETURN VARCHAR2;

END ASG_CUSTOM_PVT;

 

/
