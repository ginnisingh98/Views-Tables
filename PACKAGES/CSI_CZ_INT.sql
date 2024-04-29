--------------------------------------------------------
--  DDL for Package CSI_CZ_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CZ_INT" AUTHID CURRENT_USER AS
/* $Header: csigczis.pls 120.1 2005/10/25 17:58:21 srramakr noship $ */

  TYPE config_query_record IS RECORD(
    config_header_id         number := fnd_api.g_miss_num,
    config_revision_number   number := fnd_api.g_miss_num);

  TYPE config_query_table IS TABLE OF config_query_record INDEX BY BINARY_INTEGER;

  TYPE config_pair_record IS RECORD(
    subject_header_id        number := fnd_api.g_miss_num,
    subject_revision_number  number := fnd_api.g_miss_num,
    subject_item_id          number := fnd_api.g_miss_num,
    object_header_id         number := fnd_api.g_miss_num,
    object_revision_number   number := fnd_api.g_miss_num,
    object_item_id           number := fnd_api.g_miss_num,
    root_header_id           number := fnd_api.g_miss_num,
    root_revision_number     number := fnd_api.g_miss_num,
    root_item_id             number := fnd_api.g_miss_num, -- added the keys for root,bug 3892929
    -- sub_header_id_locked     number := fnd_api.g_miss_num, -- added all the below for MACD locking, bug4147624
    -- sub_item_id_locked       number := fnd_api.g_miss_num,
    -- sub_rev_num_locked       number := fnd_api.g_miss_num,
    -- obj_header_id_locked     number := fnd_api.g_miss_num,
    -- obj_item_id_locked       number := fnd_api.g_miss_num,
    -- obj_rev_num_locked       number := fnd_api.g_miss_num,
    source_application_id    number := fnd_api.g_miss_num,
    source_txn_header_ref    varchar2(30) := fnd_api.g_miss_char,
    source_txn_line_ref1     varchar2(30):= fnd_api.g_miss_char,
    source_txn_line_ref2     varchar2(30):= fnd_api.g_miss_char,
    source_txn_line_ref3     varchar2(30):= fnd_api.g_miss_char,
    lock_id                  number := fnd_api.g_miss_num,
    lock_status              number := fnd_api.g_miss_num);

  TYPE config_pair_table IS TABLE OF config_pair_record INDEX BY BINARY_INTEGER;

  -- used for outputing in generate_config_trees and add_to_config_tree procedures
  TYPE config_model_rec_type IS RECORD
  (
    inventory_item_id  NUMBER,
    organization_id    NUMBER,
    config_hdr_id      NUMBER,
    config_rev_nbr     NUMBER,
    config_item_id     NUMBER
  );
  TYPE config_model_tbl_type IS TABLE OF config_model_rec_type INDEX BY BINARY_INTEGER;

  -- Added the following rec structure for the Item Instance Locking, Bug 4147624
  TYPE config_rec IS RECORD(
    source_application_id    number := fnd_api.g_miss_num,
    source_txn_header_ref    varchar2(30) := fnd_api.g_miss_char,
    source_txn_line_ref1     varchar2(30):= fnd_api.g_miss_char,
    source_txn_line_ref2     varchar2(30):= fnd_api.g_miss_char,
    source_txn_line_ref3     varchar2(30):= fnd_api.g_miss_char,
    instance_id              number := fnd_api.g_miss_num,
    lock_id                  number := fnd_api.g_miss_num,
    lock_status              number := fnd_api.g_miss_num,
    config_inst_hdr_id       number := fnd_api.g_miss_num,
    config_inst_item_id      number := fnd_api.g_miss_num,
    config_inst_rev_num      number := fnd_api.g_miss_num);

  TYPE config_tbl IS TABLE OF config_rec INDEX BY BINARY_INTEGER;

  PROCEDURE get_configuration_revision(
    p_config_header_id       IN     number,
    p_target_commitment_date IN     date,
    px_instance_level        IN OUT NOCOPY varchar2,
    x_install_config_rec     OUT NOCOPY    config_rec,-- Bug 4147624, item instance locking. The config keys in the rec
    x_return_status          OUT NOCOPY    varchar2,  -- would actually correspond to values of the Installed Root
    x_return_message         OUT NOCOPY    varchar2);

  PROCEDURE get_connected_configurations(
    p_config_query_table     IN     config_query_table,
    p_instance_level         IN     varchar2,
    x_config_pair_table      OUT NOCOPY    config_pair_table,
    x_return_status          OUT NOCOPY    varchar2,
    x_return_message         OUT NOCOPY    varchar2);

  PROCEDURE configure_from_html_ui(
    p_session_hdr_id IN  number,
    p_instance_id    IN  number,
    -- Added the following 3 parameters for Bug 3711457
    p_session_rev_num_old IN number,
    p_session_rev_num_new IN number,
    p_action         IN      varchar2,
    x_error_message  OUT NOCOPY varchar2,
    x_return_status  OUT NOCOPY varchar2,
    x_msg_count      OUT NOCOPY number,
    x_msg_data       OUT NOCOPY varchar2);

----------------------------------------------------------------------------------
-- API name : CSI_CONFIG_LAUNCH_PRMS
-- Package Name: CSI_JAVA_INTERFACE_PKG
-- Type : Public
-- Pre-reqs : None
-- Function: Returns the parameters necessary for launching the CZ configurator.
-- Version : Current version 1.0
-- Initial version 1.0

Procedure CSI_CONFIG_LAUNCH_PRMS
(	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level	IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	x_configurable OUT NOCOPY 	VARCHAR2,
	x_icx_sessn_tkt OUT NOCOPY VARCHAR2,
	x_db_id	 OUT NOCOPY VARCHAR2,
	x_servlet_url OUT NOCOPY VARCHAR2,
	x_sysdate OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------------------------
-- API name : is_configurable
-- Package Name: CSI_JAVA_INTERFACE_PKG
-- Type : Public
-- Pre-reqs : None
-- Function: Checks whether a config item is independently configurable or not.
-- Version : Current version 1.0
-- Initial version 1.0
-- Parameters:
-- IN: p_api_version (required), standard IN parameter
-- p_config_hdr_id (required), config_hdr_id of an instance
-- IN: p_config_hdr_id (required), config_hdr_id of an instance
-- p_config_hdr_id (required), config_hdr_id of an instance
-- p_config_rev_nbr (required), config_rev_nbr of an instance
-- p_config_item_id (required), config_item_id of an instance item
-- OUT: x_return_value, has one of the following values  FND_API.G_TRUE,
-- FND_API.G_FALSE,NULL
-- x_return_status, standard out parameter (see generate_config_trees)
-- x_msg_count, standard out parameter
-- x_msg_data, standard out parameter

PROCEDURE IS_CONFIGURABLE(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT NOCOPY  VARCHAR2
                         ,x_return_status   OUT NOCOPY  VARCHAR2
                         ,x_msg_count       OUT NOCOPY  NUMBER
                         ,x_msg_data        OUT NOCOPY  VARCHAR2
                         );


-------------------------------------------------------------------
---Start of comments
---API name         : generate_config_trees
---Type			    : Public
---Pre-reqs         : None
---Function         : calls CZ_NETWORK_API_PUB.generate_conig_trees
---Parameters       :
---IN               : p_api_version        IN  NUMBER 		   Required
---					p_tree_copy_mode     IN  VARCHAR2            Required
---					p_validation_context IN  VARCHAR2            Required
---OUT			    :
---				    : x_return_status      OUT VARCHAR2
---				      x_msg_count          OUT NUMBER
---					x_msg_data           OUT VARCHAR2
---Version: Current version :1.0
---End of comments

PROCEDURE generate_config_trees(p_api_version        IN   NUMBER,
                                p_config_query_table IN   config_query_table,
                                p_tree_copy_mode     IN   VARCHAR2,
                                x_cfg_model_tbl   OUT NOCOPY config_model_tbl_type,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2
				        );

  -- Added the following new API's for the Item Instance Locking, Bug 4147624

  Function check_item_instance_lock (
        p_init_msg_list    IN   VARCHAR2 := FND_API.g_false,
        p_config_rec       IN   config_rec,
        x_return_status    OUT  NOCOPY VARCHAR2,
        x_msg_count        OUT  NOCOPY NUMBER,
        x_msg_data         OUT  NOCOPY VARCHAR2)
     RETURN BOOLEAN;

  PROCEDURE lock_item_instances(
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2 := FND_API.g_false,
        p_commit             IN VARCHAR2 := FND_API.g_false,
        p_validation_level   IN NUMBER  := FND_API.g_valid_level_full,
        px_config_tbl        IN OUT NOCOPY config_tbl,
        x_return_status      OUT NOCOPY    varchar2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2 );

  PROCEDURE Unlock_Current_Node(
	  p_api_version        IN NUMBER,
	  p_init_msg_list      IN VARCHAR2 := FND_API.g_false,
	  p_commit             IN VARCHAR2 := FND_API.g_false,
	  p_validation_level   IN NUMBER := FND_API.g_valid_level_full,
	  p_config_rec         IN config_rec,
	  x_conn_config_tbl    OUT NOCOPY config_tbl,
	  x_return_status      OUT NOCOPY    varchar2,
	  x_msg_count          OUT NOCOPY NUMBER,
	  x_msg_data           OUT NOCOPY VARCHAR2 );

  PROCEDURE unlock_item_instances(
        p_api_version        IN NUMBER,
        p_init_msg_list      IN VARCHAR2 := FND_API.g_false,
        p_commit             IN VARCHAR2 := FND_API.g_false,
        p_validation_level   IN NUMBER  := FND_API.g_valid_level_full,
        p_config_tbl         IN config_tbl,
        x_return_status      OUT NOCOPY    varchar2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2 );

END csi_cz_int;

 

/
