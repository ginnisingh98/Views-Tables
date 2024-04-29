--------------------------------------------------------
--  DDL for Package IEM_EMAILPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAILPROC_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvruls.pls 120.0.12010000.2 2009/07/13 04:14:14 lkullamb ship $ */
--
--
-- Purpose: Mantain Email Processing Rules Engine related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   8/1/2002    Created
--  Liang Xia   11/15/2002  Added dynamic Classification
--                          Fixed NOCOPY, FND_API.G_MISS.. GSCC warning
--  Liang Xia   12/04/2002  Completely fixed NOCOPY FND_API.G_MISS GSCC warning
--  Liang Xia   02/11/2003  Fixed bug2797418:invalid object because of spec-body miss match
--  Liang Xia   06/10/2003  Added Document Retrieval Rule type
--  Liang Xia   08/11/2003  Added Auto-Redirect Rule type
-- ---------   ------  ------------------------------------------
    G_PKG_NAME VARCHAR2(256) := 'IEM_EMAILPROC_PVT';
    G_EMAILPROC_ID varchar2(30) ;
    G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

    G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

  TYPE emailProc_rec is RECORD (
    emailProc_id        number,
    Name                varchar2(256),
    description         varchar2(256),
    type                varchar2(30), --STATIC or DYNAMIC
    rule_type           varchar2(30),
    created_by          varchar2(256),
    action              varchar2(30),
    creation_date       varchar2(50)
    );

  --Table of emailProc_rec
  TYPE emailProc_tbl is TABLE OF emailProc_rec INDEX BY BINARY_INTEGER;

  TYPE acctEmailProc_rec is RECORD (
    Account_emailProc_id    number,
    emailProc_id            number,
    name                    varchar2(256),
    description             varchar2(256),
    type                    varchar2(30), --STATIC or DYNAMIC
    rule_type               varchar2(30),
    action                  varchar2(30),
    priority                number,
    enabled_flag            varchar2(1)
    );

  --Table of acctEmailProc_rec
  TYPE acctEmailProc_tbl is TABLE OF acctEmailProc_rec INDEX BY BINARY_INTEGER;


--  Start of Comments
--  API name    : loadEmailProc
--  Type        : Private
--  Function    : This procedure load all email processing rules
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE loadEmailProc (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_classification      OUT NOCOPY emailProc_tbl,
                 x_autoDelete          OUT NOCOPY emailProc_tbl,
                 x_autoAck             OUT NOCOPY emailProc_tbl,
                 x_autoProc            OUT NOCOPY emailProc_tbl,
                 x_redirect            OUT NOCOPY emailProc_tbl,
                 x_3Rs                 OUT NOCOPY emailProc_tbl,
                 x_document            OUT NOCOPY emailProc_tbl,
                 x_route               OUT NOCOPY emailProc_tbl,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 );

PROCEDURE loadAcctEmailProc (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
		    	 p_acct_id             IN   NUMBER,
                 x_classification      OUT  NOCOPY acctEmailProc_tbl,
                 x_autoDelete          OUT  NOCOPY acctEmailProc_tbl,
                 x_autoAck             OUT  NOCOPY acctEmailProc_tbl,
                 x_autoProc            OUT  NOCOPY acctEmailProc_tbl,
                 x_redirect            OUT  NOCOPY acctEmailProc_tbl,
                 x_3Rs                 OUT  NOCOPY acctEmailProc_tbl,
                 x_document            OUT  NOCOPY acctEmailProc_tbl,
                 x_route               OUT  NOCOPY acctEmailProc_tbl,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 );

 PROCEDURE deleteAcctEmailProc (
                p_api_version_number  IN   NUMBER,
                p_init_msg_list       IN   VARCHAR2 := null,
                p_commit              IN   VARCHAR2 := null,
                p_acct_id             IN   NUMBER,
                p_rule_type           In   VARCHAR2,
                p_emailProc_id        IN   NUMBER,
                x_return_status       OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2
    );

   --update iem_routes, update iem_route_rules, insert iem_route_rules
PROCEDURE update_emailproc_wrap (
                             p_api_version_number       IN   NUMBER,
 	                         p_init_msg_list            IN   VARCHAR2 := null,
	                         p_commit	                IN   VARCHAR2 := null,
	                         p_emailproc_id             IN   NUMBER,
  	                         p_name                     IN   VARCHAR2:= null,
  	                         p_ruling_chain	            IN   VARCHAR2:= null,
                             p_description              IN   VARCHAR2:= null,
                             p_all_email                IN   VARCHAR2:= null,
                             p_rule_type                IN   VARCHAR2:= null,

                             --below is the data for update
                             p_update_rule_ids_tbl      IN  jtf_varchar2_Table_100,
                             p_update_rule_keys_tbl     IN  jtf_varchar2_Table_100,
  	                         p_update_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_values_tbl   IN  jtf_varchar2_Table_300,
                             --below is the data for insert
                             p_new_rule_keys_tbl        IN  jtf_varchar2_Table_100,
  	                         p_new_rule_operators_tbl   IN  jtf_varchar2_Table_100,
                             p_new_rule_values_tbl      IN  jtf_varchar2_Table_300,
                             --below is the data to be removed
                             p_remove_rule_ids_tbl      IN  jtf_varchar2_Table_100,
                             --below is the action and action parameter to be updated
                             p_action                    IN VARCHAR2 :=null,
                             p_parameter1_tbl            IN jtf_varchar2_Table_300,
                             p_parameter2_tbl            IN jtf_varchar2_Table_300,
                             p_parameter3_tbl            IN jtf_varchar2_Table_300,
                             p_parameter_tag_tbl         IN jtf_varchar2_Table_100,

                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2 );

-- ***************************************************************************
--  Start of Comments
--  API name    : create_emailproc_wrap
--  Type        : Private
--  Function    : This procedure is a wrap function to create Email Processing involved
--                inserting tuple in iem_emailprocs table and iem_emailproc_rules table
--  Pre-reqs    : None.
-- End of comments
-- ***********************************************************************
PROCEDURE create_emailproc_wrap (
                p_api_version_number        IN   NUMBER,
                p_init_msg_list             IN   VARCHAR2 := null,
                p_commit                    IN   VARCHAR2 := null,
                p_route_name                IN   VARCHAR2,
     	        p_route_description         IN   VARCHAR2:= null,
                p_route_boolean_type_code   IN   VARCHAR2,
                p_rule_type                 IN   VARCHAR2,
                p_action                    IN   VARCHAR2,
                p_all_email                 IN   VARCHAR2,
                p_rule_key_typecode_tbl     IN  jtf_varchar2_Table_100 ,
                p_rule_operator_typecode_tbl IN  jtf_varchar2_Table_100,
                p_rule_value_tbl            IN  jtf_varchar2_Table_300,
                p_parameter1_tbl            IN jtf_varchar2_Table_300 ,
                p_parameter2_tbl            IN jtf_varchar2_Table_300 ,
                p_parameter3_tbl            IN jtf_varchar2_Table_300 ,
                p_parameter_tag_tbl         IN jtf_varchar2_Table_100 ,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 );

-- ************************************************************************
--  Start of Comments
--  API name    : create_wrap_account_emailprocs
--  Type        : Private
--  Function    : This procedure is a wrap function to create record in iem_account_emailprocs table
--  Pre-reqs    : None.
--  Parameters  :
-- End of comments
-- *********************************************************************************************
PROCEDURE create_wrap_account_emailprocs (
                     p_api_version_number    IN NUMBER,
        		  	 p_init_msg_list         IN VARCHAR2 := null,
        		     p_commit	             IN VARCHAR2 := null,
                     p_email_account_id      IN NUMBER,
      				 p_emailproc_id          IN NUMBER,
                     p_enabled_flag          IN VARCHAR2,
                     p_priority              IN NUMBER,
                     x_return_status	     OUT NOCOPY VARCHAR2,
      		  	     x_msg_count	         OUT NOCOPY NUMBER,
    	  	  	     x_msg_data	             OUT NOCOPY VARCHAR2
			 );

-- ************************************************************************
--  Start of Comments
--  API name    : update_wrap_account_emailprocs
--  Type        : Private
--  Function    : This procedure is a wrap function to update record in iem_account_emailprocs
--  Pre-reqs    : None.
--  Parameters  :
-- End of comments

-- *********************************************************************************************
PROCEDURE update_wrap_account_emailprocs (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
                 p_email_account_id     IN   NUMBER,
  				 p_emailproc_ids_tbl    IN  jtf_varchar2_Table_100,
                 p_upd_enable_flag_tbl  IN  jtf_varchar2_Table_100,
                 p_delete_emailproc_ids_tbl IN  jtf_varchar2_Table_100,
                 p_rule_type            IN varchar2,
                 x_return_status	    OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT NOCOPY VARCHAR2
			 ) ;


 --  Start of Comments
--  API name    : delete_item_emailproc
--  Type        : Private
--  Function    : This procedure delete a batch of records in the table IEM_EMAILPROCS
--  Pre-reqs    : None.
--  Parameters  :
-- End of comments
-- ***************************************************************************
PROCEDURE delete_item_emailproc
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_emailproc_id            IN  NUMBER,
              p_rule_type               IN  VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);


PROCEDURE delete_acct_emailproc_by_acct
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_account_id        IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

END IEM_EMAILPROC_PVT;

/
