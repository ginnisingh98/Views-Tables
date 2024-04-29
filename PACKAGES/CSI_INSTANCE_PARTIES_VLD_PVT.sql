--------------------------------------------------------
--  DDL for Package CSI_INSTANCE_PARTIES_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INSTANCE_PARTIES_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csivipvs.pls 120.0 2005/05/24 17:47:45 appldev noship $ */

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_num
(
	p_number        IN      NUMBER,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_char
(
	p_variable      IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Check_Reqd_Param                          */
/* Description : To Check if the reqd parameter is passed    */
/*-----------------------------------------------------------*/

PROCEDURE Check_Reqd_Param_date
(
	p_date          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Rel_Comb_Exists                  */
/* Description : Check if the Party relationship combination */
/*                     exists already                        */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Rel_Comb_Exists
(
    p_instance_id         IN      NUMBER      ,
    p_party_source_table  IN      VARCHAR2    ,
    p_party_id            IN      NUMBER      ,
    p_relationship_type   IN      VARCHAR2    ,
    p_contact_flag        IN      VARCHAR2    ,
    p_contact_ip_id       IN      NUMBER      ,
    p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_PartyID_exists                    */
/* Description : Check if the Instance Party Id exists       */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_PartyID_exists
(
 p_Instance_party_id     IN      NUMBER,
 p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_partyID_Expired                   */
/* Description : Check if the instance_party_id              */
/*               is expired                                  */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_partyID_Expired
(
 p_Instance_party_id     IN      NUMBER,
 p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_InstanceID_Valid                       */
/* Description : Check if the Instance Id exists             */
/*-----------------------------------------------------------*/

FUNCTION Is_InstanceID_Valid
(
	p_instance_id       IN      NUMBER,
	p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_Source_tab_Valid                   */
/* Description : Check if the Party Source Table is          */
/*              defined in fnd_lookups                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Pty_Source_tab_Valid
(   p_party_source_table    IN VARCHAR2,
    p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Valid                            */
/* Description : Check if the Party Id exists in hz_parties  */
/*    po_vendors , employee  depending on party_source_table */
/*         value                                             */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Valid
(	p_party_source_table    IN      VARCHAR2,
        p_party_id              IN      NUMBER ,
	p_contact_flag          IN      VARCHAR2,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_Rel_type_Valid                     */
/* Description : Check if the Party relationship type code   */
/*         exists in fnd_lookups table                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Pty_Rel_type_Valid
(      p_party_rel_type_code   IN      VARCHAR2,
       p_contact_flag          IN      VARCHAR2,
       p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Contact_Valid                          */
/* Description : Check if it is defined as a contact for     */
/*         party_id in hz_party_relationships                */
/*-----------------------------------------------------------*/

FUNCTION Is_Contact_Valid
( p_contact_party_id          IN      NUMBER,
  p_contact_source_table      IN      VARCHAR2,
  p_ip_contact_id             IN      NUMBER,
  p_stack_err_msg             IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_StartDate_Valid                        */
/* Description : Check if party relationship active start    */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_EndDate_Valid                          */
/* Description : Check if party relationship active end      */
/*    date is valid                                          */
/*-----------------------------------------------------------*/

FUNCTION Is_EndDate_Valid
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_id           IN   NUMBER,
    p_instance_party_id     IN   NUMBER,
    p_txn_id                IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_Owner_exists                      */
/* Description : Check if owner exists for instance_id       */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_Owner_exists
( p_Instance_id   IN      NUMBER,
  p_instance_party_id IN  NUMBER,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: gen_inst_party_id                         */
/* Description : Generate instance_party_id from the sequence*/
/*-----------------------------------------------------------*/

FUNCTION gen_inst_party_id
 RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name: gen_inst_party_hist_id                    */
/* Description : Generate instance_party_history_id          */
/*               from the sequence                           */
/*-----------------------------------------------------------*/

FUNCTION gen_inst_party_hist_id
 RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Instance_creation_complete             */
/* Description : Check if the instance creation is           */
/*               complete                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_creation_complete
( p_Instance_id   IN      NUMBER,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_Acct_Comb_Exists                   */
/* Description : Check if the party account combination      */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_Pty_Acct_Comb_Exists
(
   p_instance_party_id    IN   NUMBER ,
   p_party_account_id     IN   NUMBER ,
   p_relationship_type    IN   VARCHAR2,
   p_stack_err_msg        IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_Exists                      */
/* Description : Check if the IP_account_id                  */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_Exists
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Inst_partyID_Valid                     */
/* Description : Check if the instance_party_id              */
/*               exists in csi_i_parties                     */
/*-----------------------------------------------------------*/

FUNCTION Is_Inst_partyID_Valid
(
 p_Instance_party_id     IN      NUMBER,
 p_txn_type_id           IN      NUMBER,   -- Added for bug 3550541
 p_mode                  IN      VARCHAR2, -- Added for bug 3550541
 p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Pty_accountID_Valid                    */
/* Description : Check if the party account_id               */
/*               exists in hz_cust_accounts                  */
/*-----------------------------------------------------------*/


FUNCTION Is_Pty_accountID_Valid
(  p_party_account_id       IN      NUMBER,
   p_instance_party_id      IN      NUMBER,
   p_relationship_type_code IN      VARCHAR2,
   p_txn_type_id            IN      NUMBER,   -- Added for bug 3550541
   p_mode                   IN      VARCHAR2, -- Added for bug 3550541
   p_stack_err_msg          IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_Rel_type_Valid                    */
/* Description : Check if the Party account relationship     */
/*               type code exists in fnd_lookups             */
/*-----------------------------------------------------------*/

FUNCTION  Is_Acct_Rel_type_Valid
(      p_acct_rel_type_code    IN      VARCHAR2,
       p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_StartDate_Valid                   */
/* Description : Check if the Account active Start date      */
/*               is valid                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Acct_StartDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_party_id     IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Acct_EndDate_Valid                     */
/* Description : Check if the Account active End date        */
/*               is valid                                    */
/*-----------------------------------------------------------*/

FUNCTION Is_Acct_EndDate_Valid
(   p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_inst_party_id         IN   NUMBER,
    p_ip_account_id         IN   NUMBER,
    p_txn_id                IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: generate_ip_account_id                    */
/* Description : Generate ip_account_id from the sequence    */
/*-----------------------------------------------------------*/


FUNCTION gen_ip_account_id
 RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name: generate_ip_account_hist_id               */
/* Description : Generate ip_account_hist_id from            */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ip_account_hist_id
 RETURN NUMBER;

/*------------------------------------------------------------*/
/* Procedure name: Is_datetimestamp_Valid                     */
/* Description : Check if datetimestamp is greater than       */
/*  start effective date but less than the end effective date */
/*------------------------------------------------------------*/

FUNCTION Is_timestamp_Valid
(   p_datetimestamp         IN   DATE,
    p_instance_id           IN   NUMBER,
    p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: generate_ver_label_id                     */
/* Description : Generate version_label_id  from            */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ver_label_id
  RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Ver_labelID_exists                     */
/* Description : Check if the version_label_id               */
/*               exists in csi_i_version_labels              */
/*-----------------------------------------------------------*/

FUNCTION Is_Ver_labelID_exists
(	p_version_label_id      IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: generate_ver_label_hist_id                */
/* Description : Generate version_label_hist_id  from        */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION gen_ver_label_hist_id
  RETURN NUMBER;

/*-----------------------------------------------------------*/
/* Procedure name:   generate_inst_asset_id                  */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_id
  RETURN NUMBER;


/*-----------------------------------------------------------*/
/* Procedure name:  Is_Inst_assetID_exists                   */
/* Description : Check if the instance asset id              */
/*               exists in csi_i_assets                      */
/*-----------------------------------------------------------*/

FUNCTION  Is_Inst_assetID_exists

(	p_instance_asset_id     IN      NUMBER,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN ;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Update_Status_Exists                   */
/* Description : Check if the update status  is              */
/*              defined in fnd_lookups                       */
/*-----------------------------------------------------------*/

FUNCTION Is_Update_Status_Exists
(
    p_update_status         IN      VARCHAR2,
    p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Quantity_Valid                         */
/* Description : Check if the asset quantity > 0             */
/*-----------------------------------------------------------*/

FUNCTION Is_Quantity_Valid
(
    p_asset_quantity        IN      NUMBER,
    p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name:   generate_inst_asset_hist_id             */
/* Description : Generate instance asset id   from           */
/*                           the sequence                    */
/*-----------------------------------------------------------*/

FUNCTION  gen_inst_asset_hist_id
  RETURN NUMBER;
/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Comb_Valid                      */
/* Description : Check if the instance asset id and location */
/*               id exists in fa_books                       */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Comb_Valid

(   p_asset_id        IN      NUMBER,
    p_book_type_code  IN      VARCHAR2,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name:  Is_Asset_Location_Valid                  */
/* Description : Check if the instance location id           */
/*                exists in csi_a_locations                  */
/*-----------------------------------------------------------*/

FUNCTION  Is_Asset_Location_Valid
(	p_location_id     IN      NUMBER,
    p_stack_err_msg   IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_expired                     */
/* Description : Check if the IP_account_id                  */
/*               is expired                                  */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_expired
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_IP_account_Valid                       */
/* Description : Check if the IP_account_id                  */
/*               exists in csi_ip_accounts                   */
/*-----------------------------------------------------------*/

FUNCTION Is_IP_account_Valid
(	p_ip_account_id       IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN ;

/*-----------------------------------------------------------*/
/* Procedure name: Is_bill_to_add_valid                      */
/* Description : Check if the Bill to address                */
/*               exists in hz_cust_site_uses                 */
/*-----------------------------------------------------------*/

FUNCTION Is_bill_to_add_valid
(	p_bill_to_add_id      IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_ship_to_add_valid                      */
/* Description : Check if the Ship to address                */
/*               exists in hz_cust_site_uses                 */
/*-----------------------------------------------------------*/

FUNCTION Is_ship_to_add_valid
(	p_ship_to_add_id      IN      NUMBER,
	p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Contact_Exists                   */
/* Description : Check if the Party relationship combination */
/*                     exists already                        */
/*-----------------------------------------------------------*/

FUNCTION Is_Party_Contact_Exists
(  p_contact_ip_id        IN      NUMBER      ,
   p_stack_err_msg        IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Acct_Rules_Check                          */
/* Description : Check if specific  party account            */
/*               rules are ok                                */
/*-----------------------------------------------------------*/

FUNCTION Acct_Rules_Check
(
   p_instance_party_id    IN   NUMBER ,
   p_relationship_type    IN   VARCHAR2,
   p_stack_err_msg        IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Get_Party_relation                        */
/* Description : Get Party relationhip                       */
/*-----------------------------------------------------------*/

FUNCTION Get_Party_relation
( p_Instance_party_id     IN      NUMBER,
  p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN VARCHAR2;

/*-----------------------------------------------------------*/
/* Procedure name: Get_Party_Record                          */
/* Description : Get Party Record for the account            */
/*-----------------------------------------------------------*/

FUNCTION Get_Party_Record
( p_Instance_party_id     IN      NUMBER,
  p_party_rec             OUT  NOCOPY   csi_datastructures_pub.party_rec,
  p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Account_Expired                        */
/* Description : Is the account expired                      */
/*-----------------------------------------------------------*/

FUNCTION Is_Account_Expired
  (p_party_account_rec    IN  csi_datastructures_pub.party_account_rec
  ,p_stack_err_msg        IN  BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN;



/*-----------------------------------------------------------*/
/* Procedure name: Is_Party_Expired                          */
/* Description : Is the party expired                        */
/*-----------------------------------------------------------*/
FUNCTION Is_Party_Expired
  (   p_party_rec                   IN  csi_datastructures_pub.party_rec
     ,p_stack_err_msg               IN  BOOLEAN DEFAULT TRUE
  ) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Transfer_Party_Rules                      */
/* Description : Expire accounts of the party if party is    */
/*               being changed                               */
/*-----------------------------------------------------------*/

PROCEDURE Transfer_Party_Rules
 (    p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_rec                   IN  csi_datastructures_pub.party_rec
     ,p_stack_err_msg               IN  BOOLEAN DEFAULT TRUE
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
 );

/*-----------------------------------------------------------*/
/* Procedure name: Is_Preferred_Contact_Pty                  */
/* Description : Check if Preferred party exist for the      */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Preferred_Contact_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

/*-----------------------------------------------------------*/
/* Procedure name: Is_Primary_Contact_Pty                    */
/* Description : Check if Primary party exist for the        */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Primary_Contact_Pty
( p_Instance_id         IN      NUMBER,
  p_contact_ip_id       IN      NUMBER,
  p_relationship_type   IN      VARCHAR2,
  p_start_date          IN      DATE,
  p_end_date            IN      DATE,
  p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Primary_Pty                            */
/* Description : Check if Primary party exist for the        */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Primary_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_end_date            IN      DATE        ,
  p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;


/*-----------------------------------------------------------*/
/* Procedure name: Is_Preferred_Pty                          */
/* Description : Check if Preferred party exist for the      */
/*                current party relationship                 */
/*-----------------------------------------------------------*/

FUNCTION Is_Preferred_Pty
( p_Instance_id         IN      NUMBER,
  p_relationship_type   IN      VARCHAR2    ,
  p_start_date          IN      DATE        ,
  p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
 ) RETURN BOOLEAN;

FUNCTION get_parties
(
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    p_instance_party_id     IN   NUMBER,
    p_txn_id                IN   NUMBER
)
RETURN BOOLEAN;


END CSI_Instance_parties_vld_pvt ;

 

/
