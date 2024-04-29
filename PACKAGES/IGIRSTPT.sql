--------------------------------------------------------
--  DDL for Package IGIRSTPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRSTPT" AUTHID CURRENT_USER AS
-- $Header: igistpds.pls 120.3.12000000.3 2007/09/24 05:06:11 gkumares ship $
PROCEDURE Create_Ra_Interface (p_net_batch_id       in        number,
                               p_set_of_books_id    in        number,
                               p_org_id             in        number,
                               p_user_id            in        number,
                               p_login_id           in        number,
                               p_sysdate            in        date,
                               p_currency_code      in        varchar2);

 PROCEDURE Create_Ap_Interface( p_net_batch_id       in        number,
                                p_set_of_books_id    in        number,
                                p_org_id             in        number,
                                p_user_id            in        number,
                                p_login_id           in        number,
                                p_sysdate            in        date,
                                p_currency_code      in        varchar2);

 PROCEDURE Populate_Interfaces (p_net_batch_id  in number,p_org_id in number);

 PROCEDURE Initiate_Interfaces (p_net_batch_id  in number,p_org_id in number);

 PROCEDURE Submit_Batch (errbuf out NOCOPY varchar2,
			 retcode out NOCOPY varchar2,
			 p_net_batch_id  in number,
			 p_org_id in number);


 END IGIRSTPT;

 

/
