--------------------------------------------------------
--  DDL for Package Body IEM_EMAILPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAILPROC_PVT" AS
/* $Header: iemvrulb.pls 120.1.12010000.3 2009/07/13 15:21:07 shramana ship $ */

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
--  Liang Xia   06/10/2003  Added Document Retrieval Rule type
--  Liang Xia   08/11/2003  Added Auto-Redirect Rule type
--  Liang Xia   01/20/2004  Bugfix:3362872. Do not auto-redirect to the same account.
--  Liang Xia   12/03/2004   Changed for 115.11 schema: iem_mstemail_accounts. file version:115.9
--  Mina Tang	07/26/2005  Implemented soft delete for R12
-- ---------   ------  ------------------------------------------


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
			 )
IS
    l_api_name		        varchar2(30):='loadEmailProc';
    l_api_version_number    number:=1.0;

    x                    number :=1;
    l_classifications    emailProc_tbl;
    l_routes             emailProc_tbl;
    l_autoDeletes        emailProc_tbl;
    l_autoAcks           emailProc_tbl;
    l_autoProcs          emailProc_tbl;
    l_redirects          emailProc_tbl;
    l_3Rs                emailProc_tbl;
    l_documents          emailProc_tbl;

    l_action             VARCHAR2(30);

    IEM_TAG_NOT_DELETED     EXCEPTION;

    cursor c_classifications is
        select rt.route_classification_id, rt.name, rt.description, fu.user_name,
	   to_char(rt.creation_date) creation_date, rt.boolean_type_code
        from iem_route_classifications rt, fnd_user fu
        where fu.user_id = rt.created_by and rt.route_classification_id<>0 and rt.deleted_flag='N'
        order by UPPER(name) asc;

    cursor c_routes is
        select rt.route_id, rt.name, rt.description, rt.boolean_type_code, fu.user_name, to_char(rt.creation_date) creation_date
        from iem_routes rt, fnd_user fu  where fu.user_id = rt.created_by
        order by UPPER(rt.name) asc;

    cursor c_emailProcs(v_rule_type varchar2) is
        select ep.emailproc_id, ep.name, ep.description, ep.rule_type, fu.user_name, to_char(ep.creation_date) creation_date
        from iem_emailprocs ep, fnd_user fu
        where ep.created_by=fu.user_id and ep.rule_type= v_rule_type
        order by UPPER(name);
BEGIN

    --Standard Savepoint
    SAVEPOINT loadEmailProc_pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    x := 1;
    FOR v_classifications IN c_classifications LOOP
        l_classifications(x).emailProc_id := v_classifications.route_classification_id;
        l_classifications(x).name := v_classifications.name;
        l_classifications(x).description := v_classifications.description;
        l_classifications(x).rule_type := 'CLASSIFICATION';
        l_classifications(x).type := v_classifications.boolean_type_code;
        l_classifications(x).created_by := v_classifications.user_name;
        l_classifications(x).creation_date := v_classifications.creation_date;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_routes IN c_routes LOOP
        l_routes(x).emailProc_id := v_routes.route_id;
        l_routes(x).name := v_routes.name;
        l_routes(x).description := v_routes.description;
        l_routes(x).rule_type := 'ROUTE';
        l_routes(x).type := v_routes.boolean_type_code;
        l_routes(x).created_by := v_routes.user_name;
        l_routes(x).creation_date := v_routes.creation_date;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('AUTODELETE') LOOP
        l_autoDeletes(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoDeletes(x).name := v_emailProcs.name;
        l_autoDeletes(x).description := v_emailProcs.description;
        l_autoDeletes(x).rule_type := 'AUTODELETE';
        l_autoDeletes(x).created_by := v_emailProcs.user_name;
        l_autoDeletes(x).creation_date := v_emailProcs.creation_date;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('AUTOACKNOWLEDGE') LOOP
        l_autoAcks(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoAcks(x).name := v_emailProcs.name;
        l_autoAcks(x).description := v_emailProcs.description;
        l_autoAcks(x).rule_type := 'AUTOACKNOWLEDGE';
        l_autoAcks(x).created_by := v_emailProcs.user_name;
        l_autoAcks(x).creation_date := v_emailProcs.creation_date;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('AUTORRRS') LOOP
        l_3Rs(x).emailProc_id := v_emailProcs.emailproc_id;
        l_3Rs(x).name := v_emailProcs.name;
        l_3Rs(x).description := v_emailProcs.description;
        l_3Rs(x).rule_type := 'RRRS';
        l_3Rs(x).created_by := v_emailProcs.user_name;
        l_3Rs(x).creation_date := v_emailProcs.creation_date;

        select action into l_action from iem_actions
            where emailproc_id = v_emailProcs.emailproc_id;
        l_3Rs(x).action := l_action;

        x := x + 1;

    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('DOCUMENTRETRIEVAL') LOOP
        l_documents(x).emailProc_id := v_emailProcs.emailproc_id;
        l_documents(x).name := v_emailProcs.name;
        l_documents(x).description := v_emailProcs.description;
        l_documents(x).rule_type := 'DOCUMENTRETRIEVAL';
        l_documents(x).created_by := v_emailProcs.user_name;
        l_documents(x).creation_date := v_emailProcs.creation_date;

        select action into l_action from iem_actions
            where emailproc_id = v_emailProcs.emailproc_id;
        l_documents(x).action := l_action;

        x := x + 1;

    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('AUTOPROCESSING') LOOP
        l_autoProcs(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoProcs(x).name := v_emailProcs.name;
        l_autoProcs(x).description := v_emailProcs.description;
        l_autoProcs(x).rule_type := 'AUTOPROCESSING';
        l_autoProcs(x).created_by := v_emailProcs.user_name;
        l_autoProcs(x).creation_date := v_emailProcs.creation_date;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs('AUTOREDIRECT') LOOP
        l_redirects(x).emailProc_id := v_emailProcs.emailproc_id;
        l_redirects(x).name := v_emailProcs.name;
        l_redirects(x).description := v_emailProcs.description;
        l_redirects(x).rule_type := 'AUTOREDIRECT';
        l_redirects(x).created_by := v_emailProcs.user_name;
        l_redirects(x).creation_date := v_emailProcs.creation_date;

        select action into l_action from iem_actions
            where emailproc_id = v_emailProcs.emailproc_id;
        l_redirects(x).action := l_action;

        x := x + 1;
    END LOOP;

    x_classification := l_classifications;
    x_autoDelete := l_autoDeletes;
    x_autoAck := l_autoAcks;
    x_autoProc := l_autoProcs;
    x_redirect := l_redirects;
    x_3Rs := l_3Rs;
    x_document := l_documents;
    x_route := l_routes;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO loadEmailProc_pvt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO loadEmailProc_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO loadEmailProc_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END ;


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
			 )
IS
    l_api_name		        varchar2(30):='loadAcctEmailProc';
    l_api_version_number    number:=1.0;

    x                    number :=1;
    l_classifications    acctEmailProc_tbl;
    l_routes             acctEmailProc_tbl;
    l_autoDeletes        acctEmailProc_tbl;
    l_autoAcks           acctEmailProc_tbl;
    l_autoProcs          acctEmailProc_tbl;
    l_redirects          acctEmailProc_tbl;
    l_3Rs                acctEmailProc_tbl;
    l_documents          acctEmailProc_tbl;

    IEM_TAG_NOT_DELETED     EXCEPTION;

    cursor c_classifications(v_acct_Id number) is
        select a.account_route_class_id, a.priority, r.route_classification_id,
               r.name,r.description, r.boolean_type_code, a.enabled_flag
        from iem_route_classifications r, iem_account_route_class a
        where r.route_classification_id=a.route_classification_id
        and a.email_account_id = v_acct_Id and r.route_classification_id<>0 and r.deleted_flag='N'
        order by a.priority asc;

    cursor c_emailProcs( v_acct_Id number, v_rule_type varchar2) is
        select a.account_emailProc_id, a.priority, r.emailproc_id, r.name,r.description,
                a.enabled_flag
        from iem_emailprocs r, iem_account_emailprocs a
        where r.emailproc_id = a.emailproc_id and a.email_account_id = v_acct_Id
        and r.rule_type = v_rule_type order by a.priority asc;

    --used to retrieve rule types with different actions
    cursor c_emailProc_rrr( v_acct_Id number, v_rule_type varchar2) is
        select a.account_emailProc_id, a.priority, r.emailproc_id, r.name, r.description,
               b.action, a.enabled_flag
        from iem_emailprocs r, iem_account_emailprocs a, iem_actions b
        where r.emailproc_id = a.emailproc_id and a.email_account_id = v_acct_Id
        and r.rule_type = v_rule_type and a.emailproc_id = b.emailproc_id order by a.priority asc;

    cursor c_routes(v_acct_Id number) is
        select a.account_route_id, a.priority, r.route_id, r.name,r.description,
               r.boolean_type_code, a.enabled_flag
        from iem_routes r, iem_account_routes a
        where r.route_id=a.route_id and a.email_account_id = v_acct_Id
        order by a.priority asc;

BEGIN

    --Standard Savepoint
    SAVEPOINT loadAcctEmailProc_pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    x := 1;
    FOR v_classifications IN c_classifications(p_acct_id) LOOP
        l_classifications(x).account_emailProc_id := v_classifications.account_route_class_id;
        l_classifications(x).emailProc_id := v_classifications.route_classification_id;
        l_classifications(x).name := v_classifications.name;
        l_classifications(x).description := v_classifications.description;
        l_classifications(x).type := v_classifications.boolean_type_code;
        l_classifications(x).rule_type := 'CLASSIFICATION';
        l_classifications(x).priority := v_classifications.priority;
        l_classifications(x).enabled_flag := v_classifications.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_routes IN c_routes(p_acct_id) LOOP
        l_routes(x).account_emailProc_id := v_routes.account_route_id;
        l_routes(x).emailProc_id := v_routes.route_id;
        l_routes(x).name := v_routes.name;
        l_routes(x).description := v_routes.description;
        l_routes(x).rule_type := 'ROUTE';
        l_routes(x).priority := v_routes.priority;
        l_routes(x).type := v_routes.boolean_type_code;
        l_routes(x).enabled_flag := v_routes.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs(p_acct_id,'AUTODELETE') LOOP
        l_autoDeletes(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_autoDeletes(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoDeletes(x).name := v_emailProcs.name;
        l_autoDeletes(x).description := v_emailProcs.description;
        l_autoDeletes(x).rule_type := 'AUTODELETE';
        l_autoDeletes(x).priority := v_emailProcs.priority;
        l_autoDeletes(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs(p_acct_id,'AUTOACKNOWLEDGE') LOOP
        l_autoAcks(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_autoAcks(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoAcks(x).name := v_emailProcs.name;
        l_autoAcks(x).description := v_emailProcs.description;
        l_autoAcks(x).rule_type := 'AUTOACKNOWLEDGE';
        l_autoAcks(x).priority := v_emailProcs.priority;
        l_autoAcks(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProcs(p_acct_id,'AUTOPROCESSING') LOOP
        l_autoProcs(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_autoProcs(x).emailProc_id := v_emailProcs.emailproc_id;
        l_autoProcs(x).name := v_emailProcs.name;
        l_autoProcs(x).description := v_emailProcs.description;
        l_autoProcs(x).rule_type := 'AUTOPROCESSING';
        l_autoProcs(x).priority := v_emailProcs.priority;
        l_autoProcs(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProc_rrr(p_acct_id,'AUTORRRS') LOOP
        l_3Rs(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_3Rs(x).emailProc_id := v_emailProcs.emailproc_id;
        l_3Rs(x).name := v_emailProcs.name;
        l_3Rs(x).description := v_emailProcs.description;
        l_3Rs(x).rule_type := 'AUTORRRS';
        l_3Rs(x).priority := v_emailProcs.priority;
        l_3Rs(x).action := v_emailProcs.action;
        l_3Rs(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProc_rrr(p_acct_id,'DOCUMENTRETRIEVAL') LOOP
        l_documents(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_documents(x).emailProc_id := v_emailProcs.emailproc_id;
        l_documents(x).name := v_emailProcs.name;
        l_documents(x).description := v_emailProcs.description;
        l_documents(x).rule_type := 'DOCUMENTRETRIEVAL';
        l_documents(x).priority := v_emailProcs.priority;
        l_documents(x).action := v_emailProcs.action;
        l_documents(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x := 1;
    FOR v_emailProcs IN c_emailProc_rrr(p_acct_id,'AUTOREDIRECT') LOOP
        l_redirects(x).account_emailProc_id := v_emailProcs.account_emailProc_id;
        l_redirects(x).emailProc_id := v_emailProcs.emailproc_id;
        l_redirects(x).name := v_emailProcs.name;
        l_redirects(x).description := v_emailProcs.description;
        l_redirects(x).rule_type := 'AUTOREDIRECT';
        l_redirects(x).priority := v_emailProcs.priority;
        l_redirects(x).action := v_emailProcs.action;
        l_redirects(x).enabled_flag := v_emailProcs.enabled_flag;
        x := x + 1;
    END LOOP;

    x_classification := l_classifications;
    x_autoDelete := l_autoDeletes;
    x_autoAck := l_autoAcks;
    x_autoProc := l_autoProcs;
    x_redirect := l_redirects;
    x_3Rs := l_3Rs;
    x_document := l_documents;
    x_route := l_routes;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO loadAcctEmailProc_pvt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO loadAcctEmailProc_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO loadAcctEmailProc_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END ;


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
    )

IS
    l_api_name		        varchar2(30):='deleteAcctEmailProc';
    l_api_version_number    number:=1.0;
    l_delete_class_ids_tbl jtf_varchar2_Table_100:=jtf_varchar2_Table_100();

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_EMAILPROC_NOT_DELETED     EXCEPTION;
    MY_EXCEPTION    EXCEPTION;

    cursor c_actions(v_emailProc_id number) is
        select action_id from iem_actions where emailproc_id = v_emailProc_id;

BEGIN

    --Standard Savepoint
    SAVEPOINT loadAcctEmailProc_pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    IF ( p_rule_type = 'CLASSIFICATION') THEN

    l_delete_class_ids_tbl.extend;
    l_delete_class_ids_tbl(1) := to_char(p_emailProc_id);

    if ( l_delete_class_ids_tbl.count <> 0 ) then
        iem_route_class_pvt.delete_acct_class_batch
             (p_api_version_number   =>  p_api_version_number,
              P_init_msg_list   => p_init_msg_list,
              p_commit       => FND_API.G_FALSE,
              p_class_ids_tbl =>  l_delete_class_ids_tbl,

              p_account_id => p_acct_id,
              x_return_status =>  l_return_status,
              x_msg_count   =>   l_msg_count,
              x_msg_data    =>    l_msg_data) ;
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise MY_EXCEPTION;
        end if;
    end if;

    ELSIF ( p_rule_type = 'ROUTE') THEN
        -- update priority after delete an account_routes
        Update iem_account_routes set priority=priority-1
					           where email_account_id=p_acct_id
                               and priority >
                                    ( Select priority from iem_account_routes
					                  where route_id=p_emailProc_id
                                      and  email_account_id=p_acct_id);

        DELETE
        FROM IEM_ACCOUNT_ROUTES
        WHERE route_id = p_emailProc_id and email_account_id = p_acct_id;

    ELSE
        -- update priority before delete an account_emailprocs
        Update iem_account_emailprocs set priority=priority-1
					           where email_account_id=p_acct_id
                               and priority >
                                    (   Select priority from iem_account_emailprocs
					                    where emailproc_id=p_emailProc_id
                                        and  email_account_id=p_acct_id)
                               and emailproc_id in
                                    ( select emailproc_id from iem_emailprocs
                                      where rule_type = p_rule_type );
        DELETE
        FROM iem_account_emailprocs
        WHERE emailproc_id = p_emailProc_id and email_account_id = p_acct_id;

    END IF;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
    WHEN MY_EXCEPTION THEN
        ROLLBACK TO loadAcctEmailProc_pvt;

        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO loadAcctEmailProc_pvt;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO loadAcctEmailProc_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO loadAcctEmailProc_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END ;

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
                             p_action                    IN VARCHAR2 := null,
                             p_parameter1_tbl            IN jtf_varchar2_Table_300,
                             p_parameter2_tbl            IN jtf_varchar2_Table_300,
                             p_parameter3_tbl            IN jtf_varchar2_Table_300,
                             p_parameter_tag_tbl         IN jtf_varchar2_Table_100,

                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2 )is

    l_api_name              VARCHAR2(255):='update_emailproc_wrap';
    l_api_version_number    NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_action_id           IEM_ACTIONS.ACTION_ID%type;
    l_param2_count        NUMBER := 0;
    l_param3_count        NUMBER := 0;
    l_param_tag_count     NUMBER := 0;

    l_param2              VARCHAR2(256);
    l_param3              VARCHAR2(256);
    l_param_tag           VARCHAR2(30);

    IEM_NO_ROUTE_UPDATE         EXCEPTION;
    IEM_NO_RULE_UPDATE          EXCEPTION;

    IEM_RULE_NOT_DELETED        EXCEPTION;
    IEM_ROUTE_RULE_NOT_CREATED  EXCEPTION;
    IEM_ADMIN_EMAILPROC_NO_RULE EXCEPTION;
    l_IEM_FAIL_TO_CALL          EXCEPTION;
    IEM_ACTION_DTLS_NOT_CREATE  EXCEPTION;
    IEM_ADM_AUTOPRC_NO_PARAMETERS EXCEPTION;
    IEM_ADM_INVALID_PROC_NAME   EXCEPTION;
    IEM_PROC_REDIRECT_SAME_ACCT EXCEPTION;

    l_route                 NUMBER;
    l_rule_count            NUMBER;
    l_proc_name             VARCHAR2(256);
    l_all_emails            VARCHAR2(1);
    l_redirect_same_acct    NUMBER;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT  update_item_wrap;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,

        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;


-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--API Body


--check if the route_id exist before update
  select count(*) into l_route from iem_emailprocs where emailproc_id = p_emailproc_id;

  if l_route < 1 then
    raise IEM_NO_ROUTE_UPDATE;
  end if;


    --Auto-Processing: Execute Procedure/workflow validation
    if ( p_action =  'EXECPROCEDURE' ) then
        if ( p_parameter1_tbl.count < 1 ) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        elsif ( ( p_parameter1_tbl(1) is null) or (p_parameter1_tbl(1) ='')) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        else
            IEM_TAG_RUN_PROC_PVT.validProcedure(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => p_parameter1_tbl(1),
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise IEM_ADM_INVALID_PROC_NAME;
            end if;
        end if;
    --Auto-Redirect: Do not auto-redirect to the same email account validation
    elsif ( p_action =  'AUTOREDIRECT_INTERNAL' ) then
        if ( p_parameter1_tbl.count < 1 ) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        elsif ( ( p_parameter1_tbl(1) is null) or (p_parameter1_tbl(1) ='')) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        else
            select count(*) into l_redirect_same_acct
            from iem_account_emailprocs
            where email_account_id=p_parameter1_tbl(1) and emailproc_id=p_emailproc_id;

            if ( l_redirect_same_acct > 0 ) then
                raise IEM_PROC_REDIRECT_SAME_ACCT;
            end if;
        end if;

    end if;

--update iem_routes table

    iem_emailproc_hdl_pvt.update_item_emailproc(
                                p_api_version_number => l_api_version_number,
                    	  	    p_init_msg_list => FND_API.G_FALSE,
   	                            p_commit => FND_API.G_FALSE,
			                   p_emailproc_id => p_emailproc_id,
  			                   p_name => p_name,
  			                   p_description	=>p_description,
  			                   p_ruling_chain	=>p_ruling_chain,
                               p_all_email => p_all_email,
                               p_rule_type => p_rule_type,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise l_IEM_FAIL_TO_CALL;
   end if;


  --update iem_route_rules table
  if ( p_update_rule_ids_tbl.count <>0 ) then

   FOR i IN p_update_rule_ids_tbl.FIRST..p_update_rule_ids_tbl.LAST   loop
      iem_emailproc_hdl_pvt.update_item_rule(p_api_version_number => l_api_version_number,
                               p_init_msg_list => FND_API.G_FALSE,
	                           p_commit => FND_API.G_FALSE,
  			                   p_emailproc_rule_id => p_update_rule_ids_tbl(i),
  			                   p_key_type_code	=>p_update_rule_keys_tbl(i),
  			                   p_operator_type_code	=>p_update_rule_operators_tbl(i),
                               p_value => p_update_rule_values_tbl(i),
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IEM_NO_RULE_UPDATE;
      end if;
  end loop;
end if;


    -- update by deleting rules from iem_route_rules table
if ( p_remove_rule_ids_tbl.count <> 0 ) then
    FORALL i IN p_remove_rule_ids_tbl.FIRST..p_remove_rule_ids_tbl.LAST
        DELETE
        FROM IEM_EMAILPROC_RULES
        WHERE emailproc_rule_id = p_remove_rule_ids_tbl(i);

    if SQL%NOTFOUND then
        raise IEM_RULE_NOT_DELETED;
    end if;
end if;

 if ( p_new_rule_keys_tbl.count <> 0 ) then
    FOR i IN p_new_rule_keys_tbl.FIRST..p_new_rule_keys_tbl.LAST   LOOP
         iem_emailproc_hdl_pvt.create_item_emailproc_rules (p_api_version_number=>p_api_version_number,
                                 		  	     p_init_msg_list  => p_init_msg_list,
                                		    	 p_commit	   => p_commit,
                                  				 p_emailproc_id => p_emailproc_id,
                                  				 p_key_type_code	=> p_new_rule_keys_tbl(i),
                                  				 p_operator_type_code	=> p_new_rule_operators_tbl(i),
                                                 p_value =>p_new_rule_values_tbl(i),

                                                x_return_status =>l_return_status,
                                                x_msg_count   => l_msg_count,
                                                x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ROUTE_RULE_NOT_CREATED;
        end if;
     END LOOP;
  end if;

     -- check if exist at least one rule for each route

    select all_email into l_all_emails
        from iem_emailprocs where emailproc_id = p_emailproc_id;

    if  l_all_emails<>'Y' then
        select count(*) into l_rule_count from iem_emailproc_rules where emailproc_id = p_emailproc_id;

        if l_rule_count < 1 then
            raise IEM_ADMIN_EMAILPROC_NO_RULE;
        end if;
    end if;

    -- updating action
    select action_id into l_action_id from iem_actions where emailproc_id = p_emailproc_id;

    if ( p_action <> FND_API.G_MISS_CHAR ) or ( p_action is not null ) then
        update iem_actions set action=p_action where action_id = l_action_id;
    end if;

    -- updating action dtls
    delete from iem_action_dtls where action_id = l_action_id;

        if ( p_parameter2_tbl is not null ) then
            l_param2_count := p_parameter2_tbl.count;
        end if;

        if ( p_parameter3_tbl is not null ) then
            l_param3_count := p_parameter3_tbl.count;
        end if;



        if ( p_parameter_tag_tbl is not null ) then
            l_param_tag_count := p_parameter_tag_tbl.count;
        end if;

        IF ( p_parameter1_tbl is not null ) and ( p_parameter1_tbl.count > 0 )  then

            FOR i IN p_parameter1_tbl.FIRST..p_parameter1_tbl.LAST loop

                if ( i <= l_param2_count ) then
                    l_param2 := p_parameter2_tbl(i);
                else
                    l_param2 := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;

                if ( i <= l_param3_count ) then
                    l_param3 := p_parameter3_tbl(i);
                else
                    l_param3 := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;



                if ( i <= l_param_tag_count ) then
                    l_param_tag := p_parameter_tag_tbl(i);
                else
                    l_param_tag := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;

                iem_emailproc_hdl_pvt.create_item_action_dtls (
                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => FND_API.G_FALSE,
          				 p_action_id => l_action_id,
          				 p_param1	=> p_parameter1_tbl(i),
          				 p_param2	=> l_param2,
          				 p_param3	=> l_param3,
                         p_param_tag => l_param_tag,
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);

                if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    raise IEM_ACTION_DTLS_NOT_CREATE;
                end if;
            end loop;
        END IF;

    commit work;

    EXCEPTION
        WHEN l_IEM_FAIL_TO_CALL THEN
      	   ROLLBACK TO update_item_wrap;
          -- FND_MESSAGE.SET_NAME('IEM','IEM_NO_ROUTE_UPDATE');

         --  FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ADM_AUTOPRC_NO_PARAMETERS THEN
      	   ROLLBACK TO update_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_ADM_AUTOPRC_NO_PARAMETERS');

            FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_PROC_REDIRECT_SAME_ACCT THEN
      	   ROLLBACK TO update_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_PROC_REDIRECT_SAME_ACCT');

            FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ADM_INVALID_PROC_NAME THEN
      	   ROLLBACK TO update_item_wrap;
          --  FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_PROC_NAME');

          --  FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_NO_ROUTE_UPDATE THEN
      	   ROLLBACK TO update_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_NO_ROUTE_UPDATE');

            FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN IEM_NO_RULE_UPDATE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_NO_RULE_UPDATE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_RULE_NOT_DELETED THEN

      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_RULE_NOT_DELETED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ROUTE_RULE_NOT_CREATED THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_ROUTE_RULE_NOT_CREATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


         WHEN IEM_ADMIN_EMAILPROC_NO_RULE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_EMAILPROC_NO_RULE');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

         WHEN IEM_ACTION_DTLS_NOT_CREATE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACTION_DTLS_NOT_CREATE');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


        WHEN OTHERS THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;


            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END update_emailproc_wrap;

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
                p_parameter1_tbl            IN jtf_varchar2_Table_300,
                p_parameter2_tbl            IN jtf_varchar2_Table_300,
                p_parameter3_tbl            IN jtf_varchar2_Table_300,
                p_parameter_tag_tbl         IN jtf_varchar2_Table_100,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 ) is


  l_api_name            VARCHAR2(255):='create_emailproc_wrap';
  l_api_version_number  NUMBER:=1.0;

  l_emailproc_id        IEM_EMAILPROCS.EMAILPROC_ID%TYPE;
  l_route_rule_id       IEM_EMAILPROC_RULES.EMAILPROC_RULE_ID%TYPE;
  l_action_id           IEM_ACTIONS.ACTION_ID%type;
  l_param2_count        NUMBER := 0;
  l_param3_count        NUMBER := 0;
  l_param_tag_count     NUMBER := 0;

  l_param2              VARCHAR2(256);
  l_param3              VARCHAR2(256);
  l_param_tag           VARCHAR2(30);
  l_userid    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
  l_login    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);

  IEM_EMAILPROC_NOT_CREATED EXCEPTION;
  IEM_EMAILPROC_RULE_NOT_CREATED EXCEPTION;
  IEM_ACTION_NOT_CREATED    EXCEPTION;
  IEM_ACTION_DTLS_NOT_CREATE  EXCEPTION;
  IEM_ADM_AUTOPRC_NO_PARAMETERS EXCEPTION;
  IEM_ADM_INVALID_PROC_NAME   EXCEPTION;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  create_item_wrap;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
          p_api_version_number,
          l_api_name,
          G_PKG_NAME)
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
  FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    --API Body
    --Auto-Processing: Execute Procedure/workflow validation
    if ( p_action =  'EXECPROCEDURE' ) then
        if ( p_parameter1_tbl.count < 1 ) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        elsif ( ( p_parameter1_tbl(1) is null) or (p_parameter1_tbl(1) ='')) then
            raise IEM_ADM_AUTOPRC_NO_PARAMETERS;
        else
            IEM_TAG_RUN_PROC_PVT.validProcedure(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => p_parameter1_tbl(1),
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise IEM_ADM_INVALID_PROC_NAME;
            end if;
        end if;
    end if;

    --Create iem_emailprocs
      iem_emailproc_hdl_pvt.create_item_emailprocs (
                  p_api_version_number=>p_api_version_number,
                  p_init_msg_list  => p_init_msg_list,
      		      p_commit	   => FND_API.G_FALSE,
  				  p_name => p_route_name,
  				  p_description	=> p_route_description,
  				  p_boolean_type_code	=>p_route_boolean_type_code,
                  p_all_email => p_all_email,
                  p_rule_type => p_rule_type,
                  x_emailproc_id => l_emailproc_id,
                  x_return_status =>l_return_status,
                  x_msg_count   => l_msg_count,
                  x_msg_data => l_msg_data);


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_EMAILPROC_NOT_CREATED;
   end if;


    --Create iem_emailproc_rules
    if p_rule_key_typecode_tbl.count<> 0 then
    FOR i IN p_rule_key_typecode_tbl.FIRST..p_rule_key_typecode_tbl.LAST loop

        iem_emailproc_hdl_pvt.create_item_emailproc_rules (
                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => FND_API.G_FALSE,
          				 p_emailproc_id => l_emailproc_id,
          				 p_key_type_code	=> p_rule_key_typecode_tbl(i),
          				 p_operator_type_code	=> p_rule_operator_typecode_tbl(i),
                         p_value =>p_rule_value_tbl(i),
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_EMAILPROC_RULE_NOT_CREATED;
        end if;
    end loop;
    end if;

  -- create iem_actions
 -- IF ( p_rule_type = 'AUTOACKNOWLEDGE' or  p_rule_type = 'AUTOPROCESSING' or  p_rule_type = 'AUTORRRS' ) then
        iem_emailproc_hdl_pvt.create_item_actions (
                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => FND_API.G_FALSE,
                         p_emailproc_id => l_emailproc_id,
          				 p_action_name => p_action,
                         x_action_id => l_action_id,
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ACTION_NOT_CREATED;
        end if;


        if ( p_parameter2_tbl is not null ) then
            l_param2_count := p_parameter2_tbl.count;
        end if;

        if ( p_parameter3_tbl is not null ) then
            l_param3_count := p_parameter3_tbl.count;
        end if;



        if ( p_parameter_tag_tbl is not null ) then
            l_param_tag_count := p_parameter_tag_tbl.count;
        end if;

        IF ( p_parameter1_tbl is not null ) and ( p_parameter1_tbl.count > 0 )  then


            FOR i IN p_parameter1_tbl.FIRST..p_parameter1_tbl.LAST loop

                if ( i <= l_param2_count ) then
                    l_param2 := p_parameter2_tbl(i);
                else
                    l_param2 := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;

                 if ( i <= l_param3_count ) then
                    l_param3 := p_parameter3_tbl(i);
                else
                    l_param3 := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;


                if ( i <= l_param_tag_count ) then
                    l_param_tag := p_parameter_tag_tbl(i);
                else
                    l_param_tag := null; --FND_API.G_MISS_CHAR;--null; --FND_API.G_MISS_CHAR;
                end if;

                iem_emailproc_hdl_pvt.create_item_action_dtls (
                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => FND_API.G_FALSE,
          				 p_action_id => l_action_id,
          				 p_param1	=> p_parameter1_tbl(i),
          				 p_param2	=> l_param2,
          				 p_param3	=> l_param3,
                         p_param_tag => l_param_tag,
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);

                if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    raise IEM_ACTION_DTLS_NOT_CREATE;
                end if;
            end loop;
        END IF;

   -- END IF;

    IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
    END IF;

   EXCEPTION
         WHEN IEM_EMAILPROC_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ADM_AUTOPRC_NO_PARAMETERS THEN
      	   ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_ADM_AUTOPRC_NO_PARAMETERS');
            FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ADM_INVALID_PROC_NAME THEN
      	   ROLLBACK TO create_item_wrap;
           -- FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_PROC_NAME');
           -- FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_EMAILPROC_RULE_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_EMAILPROC_RULE_NOT_CREATED');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ACTION_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_ACTION_NOT_CREATED');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN IEM_ACTION_DTLS_NOT_CREATE THEN

      	     ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_ACTION_DTLS_NOT_CREATE');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN OTHERS THEN
            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END create_emailproc_wrap;



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
			 ) is
	l_api_name        		VARCHAR2(255):='create_wrap_account_emailprocs';
	l_api_version_number 	NUMBER:=1.0;
    l_count         number;
    l_account       number;
    l_redirect_same_acct number := 0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_ADMIN_ROUTE_NOT_EXIST      EXCEPTION;
    IEM_ADMIN_ACCOUNT_NOT_EXIST    EXCEPTION;
    IEM_ACCOUNT_ROUTE_NOT_UPDATED   EXCEPTION;
    IEM_NOT_REDIRECT_SAME_ACCT      EXCEPTION;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_wrap_account_routes_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,

  				    p_api_version_number,
  				    l_api_name,
  				    G_PKG_NAME)
  THEN
  	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list )
 THEN

   FND_MSG_PUB.initialize;
 END IF;


 -- Initialize API return status to SUCCESS
 x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- check if the route_id exist in iem_routes
    select count(*) into l_count from iem_emailprocs
        where emailproc_id = p_emailproc_id;

    if l_count < 1 then

        raise IEM_ADMIN_ROUTE_NOT_EXIST;
    end if;

    -- check if the account_id exist in iem_email_accounts
    -- Changed for 115.11 schema compliance
    select count(*) into l_account from iem_mstemail_accounts
        where email_account_id = p_email_account_id;

    if l_account < 1 then
        raise IEM_ADMIN_ACCOUNT_NOT_EXIST;
    end if;

    select count(*) into l_redirect_same_acct
    from iem_emailprocs a, iem_actions b, iem_action_dtls c
    where a.emailproc_id = p_emailproc_id and a.emailproc_id=b.emailproc_id
    and a.rule_type='AUTOREDIRECT' and b.action='AUTOREDIRECT_INTERNAL'
    and b.action_id=c.action_id and c.parameter1=to_char(p_email_account_id);

    if ( l_redirect_same_acct > 0 ) then
        raise IEM_NOT_REDIRECT_SAME_ACCT;
    end if;

    iem_emailproc_hdl_pvt.create_item_account_emailprocs(
                              p_api_version_number =>p_api_version_number,
                              p_init_msg_list => p_init_msg_list,
                              p_commit => p_commit,
                              p_emailproc_id =>p_emailproc_id,
                              p_email_account_id =>p_email_account_id,
                              p_enabled_flag => p_enabled_flag,
                              p_priority => p_priority,
                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IEM_ACCOUNT_ROUTE_NOT_UPDATED;

  end if;

  -- Standard Check Of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
  		COMMIT WORK;
  END IF;
  -- Standard callto get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>    x_msg_data
			);


EXCEPTION
    WHEN IEM_NOT_REDIRECT_SAME_ACCT THEN
      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_NOT_REDIRECT_SAME_ACCT');

           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ROUTE_NOT_EXIST THEN
      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NOT_EXIST');

           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


    WHEN IEM_ADMIN_ACCOUNT_NOT_EXIST THEN
      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ACCOUNT_ROUTE_NOT_UPDATED THEN

      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCOUNT_ROUTE_NOT_UPDATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data

			);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;

            x_return_status := FND_API.G_RET_STS_ERROR;
	       IF 	FND_MSG_PUB.Check_Msg_Level
			 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		     );
		  END IF;
		  FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,

        	p_data          	=>      x_msg_data

    		);

 END	create_wrap_account_emailprocs;

-- to update and delete new ruples in iem_account_routes
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
			 ) is
	l_api_name        		VARCHAR2(255):='update_wrap_account_emailprocs';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    IEM_ACCT_EMAILPROC_NOT_DELETED    EXCEPTION;
    IEM_ACCT_EMAILPROC_NOT_UPDATED   EXCEPTION;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_wrap_acct_emailproc_PVT;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)

THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN

     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- update first

 if ( p_emailproc_ids_tbl.count <> 0 ) then
  FOR i IN p_emailproc_ids_tbl.FIRST..p_emailproc_ids_tbl.LAST LOOP
        iem_emailproc_hdl_pvt.update_account_emailprocs
                            (p_api_version_number =>p_api_version_number,
                             p_init_msg_list => FND_API.G_FALSE,
                             p_commit => FND_API.G_TRUE,
                             p_emailproc_id =>  p_emailproc_ids_tbl(i),
                             p_email_account_id => p_email_account_id,
                             p_enabled_flag =>  p_upd_enable_flag_tbl(i),
                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ACCT_EMAILPROC_NOT_UPDATED;
        end if;
    END LOOP;
end if;


if ( p_delete_emailproc_ids_tbl.count <> 0 ) then
        iem_emailproc_hdl_pvt.delete_acct_emailproc_batch
             (p_api_version_number   =>  p_api_version_number,
              P_init_msg_list   => FND_API.G_FALSE,
              p_commit       => FND_API.G_TRUE,
              p_emailproc_ids_tbl =>  p_delete_emailproc_ids_tbl,
              p_account_id => p_email_account_id,
              p_rule_type => p_rule_type,
              x_return_status =>  l_return_status,
              x_msg_count   =>   l_msg_count,
              x_msg_data    =>    l_msg_data) ;
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ACCT_EMAILPROC_NOT_DELETED;
        end if;

end if;


-- Standard Check Of p_commit.
IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get

			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);

EXCEPTION

    WHEN IEM_ACCT_EMAILPROC_NOT_UPDATED THEN
      	   ROLLBACK TO update_wrap_acct_emailproc_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCT_EMAILPROC_NOT_UPDATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ACCT_EMAILPROC_NOT_DELETED THEN
      	   ROLLBACK TO update_wrap_acct_emailproc_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCT_EMAILPROC_NOT_DELETED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_wrap_acct_emailproc_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_wrap_acct_emailproc_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO update_wrap_acct_emailproc_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;

	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);
 END	update_wrap_account_emailprocs;


-- Enter further code below as specified in the Package spec.
PROCEDURE delete_item_emailproc
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_emailproc_id            IN  NUMBER,
              p_rule_type               IN  VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_item_batch';
    l_api_version_number    number:=1.0;

    CURSOR  acct_id_cursor( l_emailproc_id IN NUMBER )  IS
            select email_account_id from iem_account_emailprocs where emailproc_id = l_emailproc_id;

    CURSOR  action_id_cursor( l_emailproc_id IN NUMBER )  IS
            select action_id from iem_actions where emailproc_id = l_emailproc_id;
    IEM_ROUTE_NOT_DELETED     EXCEPTION;
BEGIN



    --Standard Savepoint
    SAVEPOINT delete_item_batch;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
            DELETE
            FROM IEM_EMAILPROCS
            WHERE emailproc_id = p_emailproc_id;

    if SQL%NOTFOUND then
        raise IEM_ROUTE_NOT_DELETED;
    end if;

    --Delete the accounts, rules associated with this route
   --if ( p_route_ids_tbl.count <> 0 ) then

    -- FOR i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST LOOP

        -- update priority after delete an account_route
        --Fixme for account rule type association
        FOR acct_id IN acct_id_cursor(p_emailproc_id)  LOOP
               Update iem_account_emailprocs set priority=priority-1

		  			           where  email_account_id=acct_id.email_account_id
                               and emailproc_id in
                                    ( select emailproc_id
                                        from iem_emailprocs
                                        where rule_type=p_rule_type )
                               and priority > (Select priority from iem_account_emailprocs
					           where emailproc_id=p_emailproc_id and email_account_id = acct_id.email_account_id);
        END LOOP;

        --remove association
        DELETE
        FROM iem_account_emailprocs
        WHERE emailproc_id = p_emailproc_id;

        --remove iem_emailproc_rules
        DELETE
        FROM IEM_EMAILPROC_RULES
        WHERE emailproc_id=p_emailproc_id;

        --remove iem_action_dtls
        FOR v_action_id IN action_id_cursor(p_emailproc_id)  LOOP
            delete from iem_action_dtls where action_id = v_action_id.action_id;
        END LOOP;

        --remove iem_email_actions
        delete from iem_actions where emailproc_id = p_emailproc_id;


    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION

   WHEN IEM_ROUTE_NOT_DELETED THEN
        ROLLBACK TO delete_item_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ROUTE_NOT_DELETED');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_item_batch;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_item_batch;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_item_batch;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_item_emailproc;


PROCEDURE delete_acct_emailproc_by_acct
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_account_id        IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_acct_emailproc_by_acct';
    l_api_version_number    number:=1.0;

BEGIN

    --Standard Savepoint
    SAVEPOINT delete_acct_emailproc_by_acct;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
            DELETE
            FROM IEM_ACCOUNT_EMAILPROCS
            WHERE email_account_id = p_email_account_id;


    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_acct_emailproc_by_acct;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get

  			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_acct_emailproc_by_acct;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_emailproc_by_acct;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);

      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_acct_emailproc_by_acct;

END IEM_EMAILPROC_PVT; -- Package Body IEM_EMAILPROC_PVT

/
