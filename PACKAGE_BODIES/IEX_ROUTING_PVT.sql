--------------------------------------------------------
--  DDL for Package Body IEX_ROUTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_ROUTING_PVT" AS
/* $Header: iexvroub.pls 120.0 2004/01/24 03:28:34 appldev noship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IEX_ROUTING_PVT';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'iexvroub.pls';
  G_APPL_ID                NUMBER := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID               NUMBER := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID             NUMBER := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID                NUMBER := FND_GLOBAL.User_Id;
  G_REQUEST_ID             NUMBER := FND_GLOBAL.Conc_Request_Id;

PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE isCustomerOverdue ( p_api_version               in  number,
                              p_init_msg_list             in  varchar2 default fnd_api.g_false,
                              p_commit                    in  varchar2 default fnd_api.g_false,
                              p_validation_level          in  number   default fnd_api.g_valid_level_full,
                              x_return_status             out NOCOPY varchar2,
                              x_msg_count                 out NOCOPY number,
                              x_msg_data                  out NOCOPY varchar2,
                              p_customer_id               in  number,
                              p_customer_overdue          out NOCOPY boolean)

AS
l_api_name         constant        varchar2(30) := 'isCustomerOverdue';
l_api_version      constant        number := 1.0;
l_blank_chr        varchar2(1) := FND_API.G_MISS_CHAR;
i                  number := 0;

/* Begin - Andre Araujo - Change the test to iex_delinquencies
CURSOR c_CustomerOverdue IS
    SELECT customer_number
          ,customer_id
          ,dso
          ,pastdue_invoices
          ,pastdue_balance
    FROM   ar_customer_accounts
    WHERE  customer_id = p_customer_id
    AND    acctd_or_entered = 'A'
    AND    customer_or_location = 'C';
*/


BEGIN
    /* Standard start of API savepoint */
        SAVEPOINT       IEX_ROUTING_PVT;

    /* Standard call to check for call compatibility */
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    /*  Initialize message list if p_init_msg_list is set to TRUE */
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
        END IF;

    /* Initialize API return status to success */

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  API body */
/* Begin - Andre Araujo - Adapt the api to iex_delinquencies_all
    i := 0;
    p_customer_overdue := FALSE;

    FOR v_isOverdue IN c_CustomerOverdue
    LOOP
        i := i + 1;
        if (v_isOverdue.pastdue_invoices > 0) or (v_isOverdue.pastdue_balance > 0) then
                p_customer_overdue := TRUE;
        end if;
    END LOOP;
*/
    SELECT count(1)
    into   i
    FROM   iex_delinquencies_all
    WHERE  party_cust_id = p_customer_id;

    if(i > 0) then
        p_customer_overdue := TRUE;
    end if;

    /* End of API body */

    /* Standard check of p_commit */
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    /*  Standard call to get message count and if count is 1, get message info */
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
 		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	    WHEN OTHERS THEN
		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END isCustomerOverdue;

PROCEDURE getCollectors     ( p_api_version               in  number,
                              p_init_msg_list             in  varchar2 default fnd_api.g_false,
                              p_commit                    in  varchar2 default fnd_api.g_false,
                              p_validation_level          in  number   default fnd_api.g_valid_level_full,
                              x_return_status             out NOCOPY varchar2,
                              x_msg_count                 out NOCOPY number,
                              x_msg_data                  out NOCOPY varchar2,
                              p_customer_id               in  number,
                              p_collectors                out NOCOPY iex_collectors_tbl_type)

AS

l_api_name         constant        varchar2(30) := 'getCollectors';
l_api_version      constant        number := 1.0;
l_blank_chr        varchar2(1) := FND_API.G_MISS_CHAR;
i                  number := 0;

CURSOR c_Collectors IS
	select distinct collector_id
		from jtf_customer_profiles_v prof, jtf_cust_accounts_all_v acct
		where acct.party_id = p_customer_id
			and prof.cust_account_id = acct.cust_account_id;

BEGIN
    /* Standard start of API savepoint */
    SAVEPOINT       IEX_ROUTING_PVT;

    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*  Initialize message list if p_init_msg_list is set to TRUE */
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
    END IF;

    /* Initialize API return status to success */

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  API body */
	i := 0;
    FOR v_Collectors IN c_Collectors
    LOOP
        i := i + 1;
		p_collectors(i) := v_Collectors.collector_id;
    END LOOP;

    /* End of API body */

    /* Standard check of p_commit */
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    /*  Standard call to get message count and if count is 1, get message info */
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
 		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	    WHEN OTHERS THEN
		ROLLBACK TO IEX_ROUTING_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END getCollectors;

END IEX_ROUTING_PVT;

/
