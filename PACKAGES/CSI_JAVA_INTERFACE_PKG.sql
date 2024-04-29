--------------------------------------------------------
--  DDL for Package CSI_JAVA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_JAVA_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: csivjis.pls 120.10 2006/09/18 09:38:31 bnarayan noship $ */

/*----------------------------------------------------*/
/* ****************Important***************************/
/* This package is created for JAVA Interface to      */
/* Installed Base(CSI). The procedures here are       */
/* subject to change without notice.                  */
/*----------------------------------------------------*/

/**** contract Record ***/

TYPE csi_output_rec_ib IS RECORD

(        contract_id               Number
		,contract_number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
		,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
		,sts_code                  OKC_K_HEADERS_B.STS_CODE%TYPE
            ,service_line_id           Number
		,service_name              VARCHAR2(300)
		,service_description       VARCHAR2(300)
            ,coverage_term_line_id     Number
		,coverage_term_name        OKC_K_LINES_V.NAME%TYPE
		,coverage_term_description OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
            ,service_start_date        Date
            ,service_end_date          Date
		,warranty_flag             Varchar2(1)
		,eligible_for_entitlement  Varchar2(1)
            ,exp_reaction_time         Date
            ,exp_resolution_time       Date
            ,status_code               Varchar2(1)
            ,status_text               Varchar2(1995)
            ,date_terminated          Date
		);

TYPE csi_output_tbl_ib IS TABLE OF csi_output_rec_ib INDEX BY BINARY_INTEGER;

TYPE csi_coverage_rec_ib IS RECORD
(
		covered_level_code			VARCHAR2(100)
		,covered_level_id			Number
);

TYPE csi_coverage_tbl_ib IS TABLE OF csi_coverage_rec_ib INDEX BY BINARY_INTEGER;

TYPE  dpl_instance_rec is RECORD
( INSTANCE_ID NUMBER);

TYPE dpl_instance_tbl IS TABLE OF dpl_instance_rec INDEX BY BINARY_INTEGER;


/*----------------------------------------------------*/
/* procedure name: create_item_instance               */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN OUT NOCOPY csi_datastructures_pub.instance_rec
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* Procedure name:  Split_Item_Instance              */
/* Description   :  This procedure is used to create */
/*                  split lines for instance         */
/*---------------------------------------------------*/

PROCEDURE Split_Item_Instance
 (
   p_api_version                  IN      NUMBER
  ,p_commit                       IN      VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list                IN      VARCHAR2 := fnd_api.g_false
  ,p_validation_level             IN      NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec          IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_quantity1                    IN      NUMBER
  ,p_quantity2                    IN      NUMBER
  ,p_copy_ext_attribs             IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_org_assignments         IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_parties                 IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_accounts                IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_asset_assignments       IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_pricing_attribs         IN      VARCHAR2 := fnd_api.g_true
  ,p_txn_rec                      IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_rec             OUT     NOCOPY csi_datastructures_pub.instance_rec
  ,x_return_status                OUT     NOCOPY VARCHAR2
  ,x_msg_count                    OUT     NOCOPY NUMBER
  ,x_msg_data                     OUT     NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* Procedure name:  Split_Item_Instance_lines        */
/* Description   :  This procedure is used to create */
/*                  split lines for instance         */
/*---------------------------------------------------*/
 PROCEDURE Split_Item_Instance_Lines
 (
   p_api_version                 IN      NUMBER
  ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
  ,p_validation_level            IN      NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec         IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs            IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_org_assignments        IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_parties                IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_accounts               IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_asset_assignments      IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_pricing_attribs        IN      VARCHAR2 := fnd_api.g_true
  ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl            OUT     NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status               OUT     NOCOPY VARCHAR2
  ,x_msg_count                   OUT     NOCOPY NUMBER
  ,x_msg_data                    OUT     NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: copy_item_instance                */
/* description :  Copies an instace from an instance */
/*---------------------------------------------------*/

PROCEDURE copy_item_instance
 (
   p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_org_assignments   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_parties           IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_contacts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_accounts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_asset_assignments IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_pricing_attribs   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_inst_children     IN         VARCHAR2 := fnd_api.g_false
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* procedure name: getContracts                       */
/* description :   procedure used to                  */
/*                 get the contract details           */
/*----------------------------------------------------*/
 PROCEDURE getContracts
 (
  product_id			IN  Number
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data			OUT NOCOPY Varchar2
  ,x_output_contracts	OUT NOCOPY csi_output_tbl_ib
 );


/*----------------------------------------------------*/
/* procedure name: Get_Coverage_For_Prod_Sch          */
/* description :   procedure used to get contract     */
/*                 coverage info for product search on*/
/*                 a given contract number            */
/*----------------------------------------------------*/
 PROCEDURE Get_Coverage_For_Prod_Sch
 (
  contract_number       IN  VARCHAR2 := fnd_api.g_miss_char
  ,x_coverage_tbl       OUT NOCOPY csi_coverage_tbl_ib
  ,x_sequence_id        OUT NOCOPY NUMBER
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data   	OUT NOCOPY Varchar2
 );

/*----------------------------------------------------*/
/* procedure name: Get_Contract_Where_Clause          */
/* description :   procedure used to get Product      */
/*                 Search where clause for a given    */
/*                 contract number                    */
/* Note, will be depricated once                      */
/* Get_Coverage_For_Prod_Sch becomes stable.          */
/*----------------------------------------------------*/
 PROCEDURE Get_Contract_Where_Clause
 (
  contract_number       IN  VARCHAR2 := fnd_api.g_miss_char
  ,instance_table_name  IN  VARCHAR2 := fnd_api.g_miss_char
  ,x_where_clause       OUT NOCOPY VARCHAR2
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data   	OUT NOCOPY Varchar2
 );

/*---------------------------------------------------*/
/* procedure name: get_history_transactions          */
/* description   : Retreive history transactions     */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE get_history_transactions
( p_api_version                IN  NUMBER
 ,p_commit                     IN  VARCHAR2 := fnd_api.g_false
 ,p_init_msg_list              IN  VARCHAR2 := fnd_api.g_false
 ,p_validation_level           IN  NUMBER   := fnd_api.g_valid_level_full
 ,p_transaction_id             IN  NUMBER
 ,p_instance_id                IN  NUMBER
 ,x_instance_history_tbl       OUT NOCOPY csi_datastructures_pub.instance_history_tbl
 ,x_party_history_tbl          OUT NOCOPY csi_datastructures_pub.party_history_tbl
 ,x_account_history_tbl        OUT NOCOPY csi_datastructures_pub.account_history_tbl
 ,x_org_unit_history_tbl       OUT NOCOPY csi_datastructures_pub.org_units_history_tbl
 ,x_ins_asset_hist_tbl         OUT NOCOPY csi_datastructures_pub.ins_asset_history_tbl
 ,x_ext_attrib_val_hist_tbl    OUT NOCOPY csi_datastructures_pub.ext_attrib_val_history_tbl
 ,x_version_label_hist_tbl     OUT NOCOPY csi_datastructures_pub.version_label_history_tbl
 ,x_rel_history_tbl            OUT NOCOPY csi_datastructures_pub.relationship_history_tbl
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
 ) ;

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
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	x_configurable	OUT 	NOCOPY VARCHAR2,
	x_icx_sessn_tkt	OUT	NOCOPY VARCHAR2,
	x_db_id		OUT	NOCOPY VARCHAR2,
	x_servlet_url	OUT	NOCOPY VARCHAR2,
	x_sysdate	OUT	NOCOPY VARCHAR2
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
-- OUT: x_return_value, has one of the following values  FND_API.G_TRUE, FND_API.G_FALSE,NULL
-- x_return_status, standard out parameter (see generate_config_trees)
-- x_msg_count, standard out parameter
-- x_msg_data, standard out parameter

PROCEDURE IS_CONFIGURABLE(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT  NOCOPY VARCHAR2
                         ,x_return_status   OUT  NOCOPY VARCHAR2
                         ,x_msg_count       OUT  NOCOPY NUMBER
                         ,x_msg_data        OUT  NOCOPY VARCHAR2
                         );




/*
procedure Name : get_instance_link_locations
description : Gets the start and end location for netwrok link item.
*/
PROCEDURE get_instance_link_locations
(
      p_api_version          IN  NUMBER
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id          IN  NUMBER
     ,x_instance_link_rec    OUT NOCOPY csi_datastructures_pub.instance_link_rec
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE get_contact_details
 (
      p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_contact_party_id            IN  NUMBER
     ,p_contact_flag                IN  VARCHAR2
     ,p_party_tbl                   IN  VARCHAR2
     ,x_contact_details             OUT NOCOPY  csi_datastructures_pub.contact_details_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    );

Procedure bld_instance_all_parents_tbl
    (
        p_subject_id      IN  NUMBER,
        p_relationship_type_code IN VARCHAR2,
        p_time_stamp IN DATE
    );


FUNCTION get_instance_all_parents
    (
        p_subject_id      IN  NUMBER,
        p_time_stamp IN DATE
    ) RETURN VARCHAR2;


 FUNCTION get_config_org_id(
 p_instance_id IN NUMBER,
 p_last_oe_order_line_id IN NUMBER)
 RETURN VARCHAR2;

PROCEDURE delete_search_oks_temp
 (
        p_sequence_id          IN  NUMBER
       ,x_return_status        OUT NOCOPY VARCHAR2
       ,x_msg_count            OUT NOCOPY NUMBER
       ,x_msg_data             OUT NOCOPY VARCHAR2
 ) ;

PROCEDURE expire_relationship
 (
      p_api_version             IN NUMBER
      ,p_commit                 IN VARCHAR2
      ,p_init_msg_list          IN VARCHAR2
      ,p_validation_level       IN NUMBER
      ,p_subject_id             IN NUMBER
      ,p_txn_rec                IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
      ,x_instance_id_lst            OUT NOCOPY csi_datastructures_pub.id_tbl
      ,x_return_status              OUT NOCOPY VARCHAR2
      ,x_msg_count                  OUT NOCOPY NUMBER
      ,x_msg_data                   OUT NOCOPY VARCHAR2
 ) ;

 FUNCTION get_instance_ids
    (
       P_instance_tbl      IN OUT  NOCOPY   dpl_instance_tbl

    )RETURN VARCHAR2;


END CSI_JAVA_INTERFACE_PKG;


 

/
