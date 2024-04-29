--------------------------------------------------------
--  DDL for Package CSI_PARTY_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PARTY_RELATIONSHIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivips.pls 120.2.12000000.1 2007/01/16 15:39:59 appldev ship $ */


g_force_expire_flag      VARCHAR2(1) := 'N';


/*------------------------------------------------------*/
/* Declare the PL/SQL tables used by the validation API */
/*------------------------------------------------------*/

TYPE PARTY_SOURCE_TAB_REC IS RECORD
  (
    party_source_table 	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
  );

TYPE PARTY_SOURCE_TBL IS TABLE OF PARTY_SOURCE_TAB_REC INDEX BY BINARY_INTEGER;
--
TYPE PARTY_ID_REC IS RECORD
  (
    party_id		NUMBER			:= FND_API.G_MISS_NUM
   ,party_source_table	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,contact_flag	VARCHAR2(1)		:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
  );

TYPE PARTY_ID_TBL IS TABLE OF PARTY_ID_REC INDEX BY BINARY_INTEGER;
--
TYPE CONTACT_REC IS RECORD
  (
    contact_party_id	NUMBER			:= FND_API.G_MISS_NUM
   ,party_source_table	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,contact_ip_id	NUMBER			:= FND_API.G_MISS_NUM
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
  );

TYPE CONTACT_TBL IS TABLE OF CONTACT_REC INDEX BY BINARY_INTEGER;
--
TYPE PARTY_REL_TYPE_REC IS RECORD
  (
    rel_type_code	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,contact_flag	VARCHAR2(1)		:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
);

TYPE PARTY_REL_TYPE_TBL IS TABLE OF PARTY_REL_TYPE_REC INDEX BY BINARY_INTEGER;
--
TYPE PARTY_COUNT_REC IS RECORD
   (
     party_source_count	 NUMBER        	:= FND_API.G_MISS_NUM
    ,party_id_count	 NUMBER        	:= FND_API.G_MISS_NUM
    ,contact_id_count    NUMBER		:= FND_API.G_MISS_NUM
    ,rel_type_count    	 NUMBER		:= FND_API.G_MISS_NUM
   );
--
TYPE INST_PARTY_REC IS RECORD
   (
     instance_party_id  	NUMBER			:= FND_API.G_MISS_NUM
    ,valid_flag		        VARCHAR2(1)		:= FND_API.G_MISS_CHAR
   );
TYPE INST_PARTY_TBL IS TABLE OF INST_PARTY_REC INDEX BY BINARY_INTEGER;
--
TYPE ACCT_REL_TYPE_REC IS RECORD
  (
    rel_type_code	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
  );
TYPE ACCT_REL_TYPE_TBL IS TABLE OF ACCT_REL_TYPE_REC INDEX BY BINARY_INTEGER;
--
TYPE SITE_USE_REC IS RECORD
  (
    Site_use_id		NUMBER			:= FND_API.G_MISS_NUM
   ,site_use_code	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
  );
TYPE SITE_USE_TBL IS TABLE OF SITE_USE_REC INDEX BY BINARY_INTEGER;
--
TYPE ACCOUNT_COUNT_REC IS RECORD
   (
     inst_party_count	NUMBER			:= FND_API.G_MISS_NUM
    ,rel_type_count	NUMBER			:= FND_API.G_MISS_NUM
    ,site_use_count	NUMBER			:= FND_API.G_MISS_NUM
   );
--
TYPE ACCT_ID_REC IS RECORD
   (
    account_id        NUMBER
   ,valid_flag        VARCHAR2(1)
   );
TYPE ACCT_ID_TBL IS TABLE OF ACCT_ID_REC INDEX BY BINARY_INTEGER;
--

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_acct_rec                     */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_acct_rec
(
  x_party_account_rec           IN OUT NOCOPY  csi_datastructures_pub.party_account_header_rec,
  p_ip_account_hist_id          IN NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY  DATE                     );

/*----------------------------------------------------------*/
/* Procedure name:  Construct_pty_from_hist                 */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_acct_from_hist
(
  x_party_account_tbl      IN OUT NOCOPY  csi_datastructures_pub.party_account_header_tbl,
  p_time_stamp             IN DATE                                ) ;

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_account_header_tbl  IN OUT NOCOPY    csi_datastructures_pub.party_account_header_tbl);

/*----------------------------------------------------------*/
/* Procedure name:  Get_Acct_Column_Values                  */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_Acct_Column_Values
(
    p_get_acct_cursor_id   IN   NUMBER      ,
    x_pty_acct_query_rec   OUT NOCOPY    csi_datastructures_pub.party_account_header_rec );

/*----------------------------------------------------------*/
/* Procedure name:  Define_Pty_Columns                      */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Acct_Columns
(
    p_get_acct_cursor_id      IN   NUMBER             ) ;


/*----------------------------------------------------------*/
/* Procedure name:  Bind_Acct_variable                      */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_Acct_variable
(
    p_pty_acct_query_rec   IN    csi_datastructures_pub.party_account_query_rec,
    p_get_acct_cursor_id   IN    NUMBER             );



/*----------------------------------------------------------*/
/* Procedure name:  Gen_Acct_Where_Clause                   */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Acct_Where_Clause
(
    p_pty_acct_query_rec      IN    csi_datastructures_pub.party_account_query_rec
   ,x_where_clause            OUT NOCOPY    VARCHAR2           );


/*----------------------------------------------------------*/
/* Procedure name:  Get_Pty_Column_Values                   */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_Pty_Column_Values
(
    p_get_pty_cursor_id    IN   NUMBER      ,
    x_party_rec            OUT NOCOPY    csi_datastructures_pub.party_header_rec );


/*----------------------------------------------------------*/
/* Procedure name:  Define_Pty_Columns                      */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Pty_Columns
(
    p_get_pty_cursor_id      IN   NUMBER             ) ;

/*----------------------------------------------------------*/
/* Procedure name:  Bind_Pty_variable                       */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_Pty_variable
(
    p_party_query_rec      IN    csi_datastructures_pub.party_query_rec,
    p_cur_get_pty_rel      IN   NUMBER             );

/*----------------------------------------------------------*/
/* Procedure name:  Gen_Pty_Where_Clause                    */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Pty_Where_Clause
(
    p_party_query_rec      IN    csi_datastructures_pub.party_query_rec
   ,x_where_clause         OUT NOCOPY    VARCHAR2           );

/*----------------------------------------------------------*/
/* Procedure name:  Construct_pty_from_hist                 */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pty_rec
(
  x_party_rec           IN OUT NOCOPY  csi_datastructures_pub.party_header_rec,
  p_inst_party_hist_id  IN NUMBER ,
  x_nearest_full_dump   IN OUT NOCOPY  DATE                     );


/*----------------------------------------------------------*/
/* Procedure name:  Construct_pty_from_hist                 */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_pty_from_hist
(
  x_party_tbl      IN OUT NOCOPY  csi_datastructures_pub.party_header_tbl,
  p_time_stamp     IN DATE                                ) ;


/*-----------------------------------------------------------*/
/* Procedure name: Create_inst_party_realationships          */
/* Description : Procedure used to create new instance-party */
/*                                 relationships             */
/*-----------------------------------------------------------*/

PROCEDURE create_inst_party_relationship
 (    p_api_version         IN  NUMBER
     ,p_commit              IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_rec           IN OUT NOCOPY   csi_datastructures_pub.party_rec
     ,p_txn_rec             IN OUT NOCOPY   csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
     ,p_party_source_tbl    IN OUT NOCOPY   csi_party_relationships_pvt.party_source_tbl
     ,p_party_id_tbl        IN OUT NOCOPY   csi_party_relationships_pvt.party_id_tbl
     ,p_contact_tbl         IN OUT NOCOPY   csi_party_relationships_pvt.contact_tbl
     ,p_party_rel_type_tbl  IN OUT NOCOPY   csi_party_relationships_pvt.party_rel_type_tbl
     ,p_party_count_rec     IN OUT NOCOPY   csi_party_relationships_pvt.party_count_rec
     ,p_called_from_grp     IN     VARCHAR2 DEFAULT fnd_api.g_false
 );


/*---------------------------------------------------------*/
/* Procedure name:  Update_inst_party_relationship         */
/* Description :   Procedure used to  update the existing  */
/*                instance -party relationships            */
/*---------------------------------------------------------*/


PROCEDURE update_inst_party_relationship
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_rec                   IN OUT NOCOPY  csi_datastructures_pub.party_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2  );


/*---------------------------------------------------------*/
/* Procedure name:  Expire_inst_party_relationship         */
/* Description :  Procedure used to  expire an existing    */
/*                instance -party relationships            */
/*---------------------------------------------------------*/

PROCEDURE expire_inst_party_relationship
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_party_rec          IN  csi_datastructures_pub.party_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2  );

/*-------------------------------------------------------------*/
/* Procedure name:  Create_inst_party_account                  */
/* Description :  Procedure used to  create new                */
/*               instance-party account relationships          */
/*-------------------------------------------------------------*/

PROCEDURE create_inst_party_account
 (    p_api_version         IN  NUMBER
     ,p_commit              IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_rec   IN OUT NOCOPY   csi_datastructures_pub.party_account_rec
     ,p_txn_rec             IN OUT NOCOPY   csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
     ,p_inst_party_tbl      IN OUT NOCOPY   csi_party_relationships_pvt.inst_party_tbl
     ,p_acct_rel_type_tbl   IN OUT NOCOPY   csi_party_relationships_pvt.acct_rel_type_tbl
     ,p_site_use_tbl        IN OUT NOCOPY   csi_party_relationships_pvt.site_use_tbl
     ,p_account_count_rec   IN OUT NOCOPY   csi_party_relationships_pvt.account_count_rec
     ,p_called_from_grp     IN     VARCHAR2 DEFAULT fnd_api.g_false
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY   oks_ibint_pub.txn_instance_tbl
 );

/*--------------------------------------------------------*/
/* Procedure name:  Update_inst_party_account             */
/* Description :  Procedure used to update the existing   */
/*                instance-party account relationships    */
/*--------------------------------------------------------*/

PROCEDURE update_inst_party_account
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_rec           IN  csi_datastructures_pub.party_account_rec
     ,p_txn_rec                     IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl            IN  OUT NOCOPY  oks_ibint_pub.txn_instance_tbl
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2    );

/*---------------------------------------------------------*/
/* Procedure name: Expire_inst_party_account               */
/* Description :  Procedure used to expire an existing     */
/*                instance-party account relationships     */
/*---------------------------------------------------------*/


PROCEDURE expire_inst_party_account
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_rec           IN  csi_datastructures_pub.party_account_rec
     ,p_txn_rec                     IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2 );


/*---------------------------------------------------------*/
/* Procedure name: get_contact_details                     */
/* Description :  Procedure used to get                    */
/*                contact details                          */
/*---------------------------------------------------------*/


 PROCEDURE get_contact_details
 (
      p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_contact_party_id            IN  NUMBER
     ,p_contact_flag                IN  VARCHAR2
     ,p_party_tbl                   IN  VARCHAR2
     ,x_contact_details             OUT NOCOPY  csi_datastructures_pub.contact_details_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2 );


/*------------------------------------------------------------*/
/* Procedure name:  get_inst_party_rel_hist                   */
/* Description :   Procedure used to  get party relationships */
/*                  from history given a transaction_id       */
/*------------------------------------------------------------*/

PROCEDURE get_inst_party_rel_hist
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_transaction_id          IN  NUMBER
     ,x_party_history_tbl       OUT NOCOPY  csi_datastructures_pub.party_history_tbl
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER
     ,x_msg_data                OUT NOCOPY  VARCHAR2
    );



/*------------------------------------------------------------*/
/* Procedure name:  get_inst_party_account_hist               */
/* Description :   Procedure used to  get party account       */
/*                  history given a transaction_id            */
/*------------------------------------------------------------*/

PROCEDURE get_inst_party_account_hist
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_transaction_id          IN  NUMBER
     ,x_account_history_tbl     OUT NOCOPY  csi_datastructures_pub.account_history_tbl
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER
     ,x_msg_data                OUT NOCOPY  VARCHAR2
    );




END csi_party_relationships_pvt ;


 

/
