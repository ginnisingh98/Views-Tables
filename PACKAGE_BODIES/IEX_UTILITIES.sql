--------------------------------------------------------
--  DDL for Package Body IEX_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UTILITIES" AS
/* $Header: iexvutlb.pls 120.27.12010000.16 2010/05/19 11:37:06 snuthala ship $ */

  G_PKG_NAME	  CONSTANT VARCHAR2(30) := 'IEX_UTILITIES';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'iexvutlb.pls';
  G_APPL_ID       NUMBER;
  G_LOGIN_ID      NUMBER;
  G_PROGRAM_ID    NUMBER;
  G_USER_ID       NUMBER;
  G_REQUEST_ID    NUMBER;

  PG_DEBUG NUMBER(2);
  --Added by schekuri for bug#4368394 on 30-NOV-2005
  G_VIEW_BY_LEVEL VARCHAR2(20);

-- start bug 7269278
Function Get_Manager_role(p_user_id in number) return varchar2 is

  l_manager varchar2(1) :=  'N';

  Cursor get_manager_role_c(l_user_id number) is
     select nvl(rol.manager_flag,'N') manager_role
       from jtf_rs_role_relations rel, jtf_rs_roles_b rol,jtf_rs_resource_extns ext
      where rel.role_resource_id = ext.resource_id
        and rol.role_id = rel.role_id
        and rol.active_flag = 'Y'
        and rol.role_code = 'IEX_MANAGER'
        and rol.role_type_code = 'COLLECTIONS'
        and (trunc(nvl(rel.start_date_active,sysdate)) <= trunc(sysdate) and trunc(nvl(rel.end_date_active,sysdate+1)) >= trunc(sysdate))
        and ext.user_id =  nvl(l_user_id,0);

  begin

    Open get_manager_role_c(p_user_id);
    Fetch get_manager_role_c into l_manager;
    return l_manager;
    Close get_manager_role_c;

   exception
     when others then
         iex_debug_pub.logmessage ('Exception from Get_Manage_Role  = ' ||SQLERRM||SQLCODE);
         return l_manager;

End Get_Manager_role;
-- end bug 7269278

Function Delete_delinquncies(p_transaction_id number) return varchar2 is
 delete_flag varchar2(1) :=  'N';

begin

 Delete from iex_delinquencies_all where transaction_id = p_transaction_id;
delete_flag := 'Y';
commit;
 return delete_flag;

exception
     when others then
         iex_debug_pub.logmessage ('Exception from Get_Manage_Role  = ' ||SQLERRM||SQLCODE);
         return delete_flag;

End Delete_delinquncies;

PROCEDURE ACCT_BALANCE
      (p_api_version      IN  NUMBER := 1.0,
       p_init_msg_list    IN  VARCHAR2,
       p_commit           IN  VARCHAR2,
       p_validation_level IN  NUMBER,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
	   p_cust_acct_id     IN  Number,
	   x_balance          OUT NOCOPY Number)
  IS
    l_api_version     CONSTANT   NUMBER := 1.0;
    l_api_name        CONSTANT   VARCHAR2(30) := 'Acct_Balance';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    amount  Number;
    total   Number;

  BEGIN
    SAVEPOINT	Acct_Balance_Pvt;

    amount    := 0;
    total     := 0;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT nvl( SUM (acctd_amount_due_remaining), 0) AMOUNT
	into Amount
	FROM AR_PAYMENT_SCHEDULES
	WHERE customer_id = p_cust_acct_id
	AND customer_id+0 = p_cust_acct_id
	AND   class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
	AND   status = 'OP'	;

	total := amount ;

	SELECT nvl(SUM (acctd_amount_due_remaining), 0) AMOUNT
	into	amount
	FROM AR_PAYMENT_SCHEDULES
	WHERE customer_id = p_cust_acct_id
	AND customer_id+0 = p_cust_acct_id
	AND class = 'PMT'
	AND status = 'OP'
	AND acctd_amount_due_remaining <> 0;

	--total := total - amount ;
	total := total + amount ;


	SELECT nvl(SUM (acctd_amount_due_remaining), 0) AMOUNT
	into amount
	FROM AR_PAYMENT_SCHEDULES
	WHERE customer_id = p_cust_acct_id
	AND customer_id+0 = p_cust_acct_id
	AND class = 'CM'
	AND status = 'OP';

	--total := total - amount ;
	total := total + amount ;
	x_balance := total ;

	-- Standard check of p_commit
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Acct_Balance_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Acct_Balance_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO Acct_Balance_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  END Acct_Balance;

PROCEDURE Validate_any_id(p_api_version   IN  NUMBER := 1.0,
                          p_init_msg_list IN  VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          p_col_id        IN NUMBER,
                          p_col_name      IN VARCHAR2,
                          p_table_name    IN VARCHAR2)
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        VARCHAR2(1);
    l_api_version   CONSTANT NUMBER := p_api_version;
    l_init_msg_list CONSTANT VARCHAR2(1) := p_init_msg_list;
    l_api_name      CONSTANT VARCHAR2(20) := 'VALIDATE_ANY_ID';
    vPlsql          VARCHAR2(2000);

    -- clchang updated for sql bind var 05/07/2003
    vstr1           VARCHAR2(100);
    vstr2           VARCHAR2(100);
    vstr3           VARCHAR2(100);
    vstr4           VARCHAR2(100);
    vstr5           VARCHAR2(100);
    vstr6           VARCHAR2(100);
    vstr7           VARCHAR2(100);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_id_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    vstr1            := ' Select ''X'' ';
    vstr2            := ' From ';
    vstr3            := ' Where exists ';
    vstr4            := '     (Select ' ;
    vstr5            := ' From ';
    vstr6            := '       Where ' ;
    vstr7            := ' = :a1)';


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
       -- clchang updated for sql bind var 05/07/2003
       vPlsql := vstr1 ||
                 vstr2 || p_table_name ||
                 vstr3 ||
                 vstr4 || p_col_name ||
                 vstr5 || p_table_name ||
                 vstr6 || p_col_name || vstr7;
     WriteLog('iexvutlb:validateid:plsql='||vPlsql);
       /*
       vPlsql :=
             ' Select ''X'' ' ||
             ' From ' || p_table_name || ' ' ||
             ' Where exists ' ||
             '     (Select ' || p_col_name ||
             '     From ' || p_table_name ||
             '     Where ' || p_col_name || ' = :a1)';
             --dbms_output.put_line('plsql is ' || vPLSQL);
       */
       -- end
        open valid_id for
            vPlsql
            using p_col_id;
        FETCH valid_id INTO count_id;

     WriteLog('iexvutlb:validateid:count_id='||count_id);

        if valid_id%FOUND then
            --dbms_output.put_line('FOUND!!');
            WriteLog('iexvutlb:validateid:Found!');
            l_return_status := FND_API.G_RET_STS_SUCCESS;
        else
            --dbms_output.put_line('NOT FOUND!!');
            WriteLog('iexvutlb:validateid:NotFound!');
            l_return_status := FND_API.G_RET_STS_ERROR;
        end if;
        CLOSE valid_id;

    x_return_status := l_return_status;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_id_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_id_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO Validate_any_id_PVT;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	END IF;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_any_id;

PROCEDURE Validate_any_varchar(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_col_value     IN  VARCHAR2,
                               p_col_name      IN  VARCHAR2,
                               p_table_name    IN  VARCHAR2)
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        VARCHAR2(1);
    l_api_version   CONSTANT NUMBER := p_api_version;
    l_init_msg_list CONSTANT VARCHAR2(1) := p_init_msg_list;
    l_api_name      CONSTANT VARCHAR2(20) := 'VALIDATE_ANY_VARCHAR';

    l_col_value varchar2(240);
    vPLSQL varchar2(1000);

    -- clchang updated for sql bind var 05/07/2003
    vstr1           VARCHAR2(100);
    vstr2           VARCHAR2(100);
    vstr3           VARCHAR2(100);
    vstr4           VARCHAR2(100);
    vstr5           VARCHAR2(100);
    vstr6           VARCHAR2(100);
    vstr7           VARCHAR2(100);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_varchar_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


    vstr1            := ' Select ''X'' ';
    vstr2            := ' From ';
    vstr3            := ' Where exists ';
    vstr4            := '     (Select ' ;
    vstr5            := ' From ';
    vstr6            := '       Where ' ;
    vstr7            := ' = :a1)';

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
        --dbms_output.put_line('col is ' || p_col_value);
       -- clchang updated for sql bind var 05/07/2003
       vPLSQL := vstr1 ||
                 vstr2 || p_table_name ||
                 vstr3 ||
                 vstr4 || p_col_name ||
                 vstr5 || p_table_name ||
                 vstr6 || p_col_name || vstr7;
       /*
        vPLSQL := ' Select ''X''   ' ||
                  ' From ' || p_table_name ||
                  ' Where exists   ' ||
                  '   (Select ' || p_col_name ||
                  '    From ' || p_table_name ||
                  '    Where ' || p_col_name || ' = :a1)';
       */
        --dbms_output.put_line('plsql is ' || vPLSQL);

        OPEN valid_id FOR
            vPLSQL
            using p_col_value;
        FETCH valid_id INTO count_id;

        if valid_id%FOUND then
            --dbms_output.put_line('FOUND!!');
            l_return_status := FND_API.G_RET_STS_SUCCESS;
        else
            --dbms_output.put_line('NOT FOUND!!');
            l_return_status := FND_API.G_RET_STS_ERROR;
        end if;
        CLOSE valid_id;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_any_varchar;

PROCEDURE Validate_Lookup_CODE(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_lookup_type   IN  VARCHAR2,
                               p_lookup_code   IN  VARCHAR2,
                               p_lookup_view   IN VARCHAR2)
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        NUMBER       := 0;
    l_api_version   CONSTANT NUMBER       := p_api_version;
    l_init_msg_list CONSTANT VARCHAR2(1)  := p_init_msg_list;
    l_api_name      CONSTANT VARCHAR2(20) := 'VALIDATE_LOOKUP_CODE';

    l_lookup_code varchar2(30);
    l_lookup_type varchar2(30);
    vPLSQL varchar2(1000);

    -- clchang updated for sql bind var 05/07/2003
    vstr1    varchar2(1000);
    vstr2    varchar2(1000);
    vstr3    varchar2(1000);
    vstr4    varchar2(1000);
    vstr5    varchar2(1000);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_varchar_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    vstr1     := 'Select Count(LOOKUP_CODE) ';
    vstr2     := 'From ';
    vstr3     := 'Where LOOKUP_TYPE = :l_lookup_type ' ;
    vstr4     := ' AND LOOKUP_CODE = :l_lookup_code ';
    vstr5     := ' AND ENABLED_FLAG = ''Y''';

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
      l_lookup_code := '''' || p_lookup_code || '''';
      l_lookup_type := '''' || p_lookup_type || '''';

      WriteLog('iexvutlb:validatelookup:lookup_code='||l_lookup_code);
      WriteLog('iexvutlb:validatelookup:lookup_type='||l_lookup_type);

        --dbms_output.put_line('col is ' || l_lookup_code);
        -- clchang updated for sql bind var 05/07/2003
        vPLSQL := vstr1 ||
                  vstr2 || p_lookup_view || ' ' ||
                  vstr3 ||
                  vstr4 ||
                  vstr5;
       /*
        vPLSQL :=
              'Select Count(LOOKUP_CODE) '  ||
              'From ' || p_lookup_view || ' ' ||
              'Where LOOKUP_TYPE = ' || l_lookup_type  || ' AND ' ||
              'LOOKUP_CODE = ' || l_lookup_code || ' AND ' ||
              'ENABLED_FLAG = ''Y''';
       */
        --

        --dbms_output.put_line('plsql is ' || vPLSQL);
       /*
        OPEN valid_id FOR
            vPLSQL;
       */


       select count(lookup_code)
         into count_id
         from iex_lookups_v
        where lookup_type = p_lookup_type
          and lookup_code = p_lookup_code
          and enabled_flag = 'Y';

      /*
        open valid_id for
            vPlsql
            using l_lookup_type, l_lookup_code;

        FETCH valid_id INTO count_id;

        CLOSE valid_id ;
      */

     WriteLog('iexvutlb:validatelookup:count_id='||count_id);

        IF (count_id > 0) then
                l_return_status := FND_API.G_RET_STS_SUCCESS;
        ELSE
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF ;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_LOOKUP_CODE;

-- added by jypark 03052002
--Begin bug#5373412 schekuri 10-Jul-2006
--Removed the following procedures and added a single consolidate procedure get_assigned_collector
/*PROCEDURE get_access_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_party_id         IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS
--Territory Assignment Changes
  CURSOR c_get_person IS
    SELECT DISTINCT ac.employee_id
    FROM  hz_customer_profiles hp,ar_collectors ac
    WHERE  hp.collector_id = ac.collector_id
    AND    ac.employee_id is not null
    AND    hp.party_id = p_party_id;

  CURSOR c_get_resource(p_person_id NUMBER) IS
    SELECT resource_id, source_id, user_id, source_name, user_name
	FROM jtf_rs_resource_extns
	WHERE source_id = p_person_id;
	--AND start_date_active <= sysdate
	--AND end_date_active > sysdate;

  l_resource_row c_get_resource%rowtype;
  l_api_version   CONSTANT NUMBER        := p_api_version;
  l_api_name      CONSTANT VARCHAR2(100) := 'GET_ACCESS_RESOURCES';
  l_init_msg_list CONSTANT VARCHAR2(1)   := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(32767);
  idx             NUMBER := 0;
BEGIN

   IF PG_DEBUG < 10  THEN
     iex_debug_pub.logmessage ('**** BEGIN get_access_resources ************');
     iex_debug_pub.logmessage ('get_person cursor = ' ||
        'SELECT DISTINCT hp.employee_id
         FROM  hz_customer_profiles hp,ar_collectors ac
         WHERE m.person_id = ac.employee_id
         AND  hp.collector_id = ac.collector_id
         and ac.employee_id is not null
         AND hp.party_id = p_party_id ' ||
        'SELECT resource_id, source_id, user_id, source_name, user_name ' ||
	'FROM jtf_rs_resource_extns ' ||
	'WHERE source_id = p_person_id');
   END IF;
  SAVEPOINT	Access_Resources_Pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_person IN c_get_person LOOP
     IF PG_DEBUG < 10  THEN
       iex_debug_pub.logmessage ('employee_id = ' || r_person.employee_id);
     END IF;
    OPEN c_get_resource(r_person.employee_id);
	FETCH c_get_resource INTO l_resource_row;
	IF c_get_resource%FOUND THEN
	  idx := idx + 1;
        IF PG_DEBUG < 10  THEN
           iex_debug_pub.logmessage ('idx= ' || idx);
           iex_debug_pub.logmessage ('l_resource_row.resource_id = ' || l_resource_row.resource_id);
           iex_debug_pub.logmessage ('l_resource_row.user_name = ' || l_resource_row.user_name);
           iex_debug_pub.logmessage ('l_resource_row.source_name = ' || l_resource_row.source_name);
        END IF;
	  x_resource_tab(idx).resource_id := l_resource_row.resource_id;
	  x_resource_tab(idx).user_id := l_resource_row.user_id;
	  x_resource_tab(idx).person_id := l_resource_row.source_id;
	  x_resource_tab(idx).user_name := l_resource_row.user_name;
	  x_resource_tab(idx).person_name := l_resource_row.source_name;
	END IF;
	CLOSE c_get_resource;
  End LOOP;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     IF PG_DEBUG < 10  THEN
       iex_debug_pub.logmessage ('**** END get_access_resources ************');
     END IF;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Access_Resources_Pvt;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Access_Resources_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO Access_Resources_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_access_resources;

PROCEDURE get_assign_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_party_id         IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS
/* cursor rewritten to avoid full table scan iex_strategy_work_items
  CURSOR c_get_person IS
    SELECT acc.person_id, acc.salesforce_id, count(work_item_id)
    FROM  as_accesses acc, jtf_rs_resource_extns rs, iex_strategy_work_items wi
    WHERE acc.customer_id = p_party_id and rs.resource_id = acc.salesforce_id
      and acc.salesforce_id = wi.resource_id(+)
      and wi.status_code(+) = 'OPEN'
      and acc.sales_lead_id is null and acc.lead_id is null
      and rs.user_id is not null
      group by acc.salesforce_id, acc.person_id ORDER BY 3;
*/
/*
--Territory Assignment Changes
  CURSOR c_get_person IS
   (
    SELECT ac.employee_id, ac.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_strategy_work_items wi,
          ar_collectors ac
    WHERE hp.party_id      = p_party_id
      and hp.cust_account_id = -1
      and rs.resource_id   = ac.resource_id
      and hp.collector_id  = ac.collector_id
      and ac.resource_id   = wi.resource_id
      and wi.status_code   = 'OPEN'
      and rs.user_id is not null
      and    ac.employee_id is not null
      group by ac.resource_id, ac.employee_id
    union all
    SELECT ac.employee_id, ac.resource_id, 0
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs,ar_collectors ac
    WHERE hp.party_id       = p_party_id
      and hp.cust_account_id = -1
      and rs.resource_id    = ac.resource_id
      and hp.collector_id   = ac.collector_id
      and rs.user_id is not null and
      not exists (select null from iex_strategy_work_items wi
            where ac.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and    ac.employee_id is not null
       group by ac.resource_id, ac.employee_id
      ) order by 3;
*/

/* We use hz_customer_profiles and
   Load balancing when the assigned with Group Resource
*/
/*cursor c_get_person IS
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.party_id = p_party_id
  and hp.cust_account_id = -1
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
  -- Bug4483896. Fixed by lkkumar. Check for inactive_date. Start.
  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
  and nvl(ac.status,'A') = 'A'
  -- Bug4483896. Fixed by lkkumar. Check for inactive_date. End.
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.party_id  = P_PARTY_ID
      and hp.cust_account_id = -1
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      -- Bug4483896. Fixed by lkkumar. Check for inactive_date. Start.
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.party_id  = p_party_id
      and hp.cust_account_id = -1
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      -- Bug4483896. Fixed by lkkumar. Check for inactive_date. Start.
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      -- Bug4483896. Fixed by lkkumar. Check for inactive_date. End.
       group by jtg.resource_id, jtg.person_id
      ) order by 3;

/*
  CURSOR c_get_person IS
    SELECT DISTINCT person_id, salesforce_id
    FROM  as_accesses acc
    WHERE acc.customer_id = p_party_id;
*/

 /* l_api_version   CONSTANT NUMBER       := p_api_version;
  l_api_name CONSTANT VARCHAR2(100) := 'GET_ASSIGN_RESOURCES';
  l_init_msg_list VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
BEGIN

     iex_debug_pub.logmessage ('**** BEGIN on all
      get_access_resources ************');
  l_init_msg_list := p_init_msg_list;
     iex_debug_pub.logmessage ('get_person cursor = ' ||
     'SELECT ac.employee_id, ac.resource_id, count(work_item_id) ' ||
     ' FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_strategy_work_items wi, '||
     ' ar_collectors ac ' ||
     ' WHERE hp.party_id      = p_party_id '    ||
     ' and rs.resource_id   = ac.resource_id'   ||
     ' and hp.collector_id  = ac.collector_id'  ||
     ' and ac.resource_id   = wi.resource_id'   ||
     ' and wi.status_code   = OPEN '   ||
     ' and rs.user_id is not null'||
     ' group by ac.resource_id, ac.employee_id ');

  SAVEPOINT	get_assign_resources;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_person IN c_get_person LOOP
     idx := idx + 1;
     iex_debug_pub.logmessage ('idx= ' || idx);
     iex_debug_pub.logmessage ('r_person.salesforce_id = ' || r_person.resource_id);
	  x_resource_tab(idx).resource_id := r_person.resource_id;
	  x_resource_tab(idx).person_id := r_person.employee_id;
  End LOOP;*/

  --use bulk collect for performance as per kasreeni's request
  --jsanju 04/13/2004
  /*
    OPEN c_get_person ;
    FETCH c_get_person BULK COLLECT INTO x_resource_tab;
    CLOSE c_get_person;
  */

  /*
  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     iex_debug_pub.logmessage ('**** END get_access_resources ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_assign_resources;

PROCEDURE get_assign_account_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_account_id         IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS
--Territory Assignment Changes
/*  CURSOR c_get_person IS
   (
    SELECT ac.employee_id, ac.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_strategy_work_items wi,
          ar_collectors ac
    WHERE hp.cust_account_id = p_account_id
      and hp.site_use_id is null
      and rs.resource_id   = ac.resource_id
      and hp.collector_id  = ac.collector_id
      and ac.resource_id   = wi.resource_id
      and wi.status_code   = 'OPEN'
      and rs.user_id is not null
      and    ac.employee_id is not null
      group by ac.resource_id, ac.employee_id
    union all
    SELECT ac.employee_id, ac.resource_id, 0
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs,ar_collectors ac
    WHERE hp.cust_account_id       = p_account_id
      and hp.site_use_id is null
      and rs.resource_id    = ac.resource_id
      and hp.collector_id   = ac.collector_id
      and rs.user_id is not null and
      not exists (select null from iex_strategy_work_items wi
            where ac.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and    ac.employee_id is not null
       group by ac.resource_id, ac.employee_id
      ) order by 3;
*/

/* We use hz_customer_profiles and
   Load balancing when the assigned with Group Resource
*/
/*CURSOR c_get_person IS
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.cust_account_id = p_account_id
  and hp.site_use_id is null
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.cust_account_id  = p_account_id
      and hp.site_use_id is NULL
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.cust_account_id  = p_account_id
      and hp.site_use_id is null
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
       group by jtg.resource_id, jtg.person_id
      ) order by 3;*/

/*
  CURSOR c_get_person IS
    SELECT DISTINCT person_id, salesforce_id
    FROM  as_accesses acc
    WHERE acc.customer_id = p_party_id;
*/

 /* l_api_version   CONSTANT NUMBER       := p_api_version;
  l_api_name CONSTANT VARCHAR2(100) := 'GET_ASSIGN_RESOURCES';
  l_init_msg_list VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
BEGIN

     iex_debug_pub.logmessage ('**** BEGIN on all
      get_access_resources ************');
  l_init_msg_list := p_init_msg_list;
     iex_debug_pub.logmessage ('get_person cursor = ' ||
     'SELECT ac.employee_id, ac.resource_id, count(work_item_id) ' ||
     ' FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_strategy_work_items wi, '||
     ' ar_collectors ac ' ||
     ' WHERE hp.party_id      = p_party_id '    ||
     ' and rs.resource_id   = ac.resource_id'   ||
     ' and hp.collector_id  = ac.collector_id'  ||
     ' and ac.resource_id   = wi.resource_id'   ||
     ' and wi.status_code   = OPEN '   ||
     ' and rs.user_id is not null'||
     ' group by ac.resource_id, ac.employee_id ');

  SAVEPOINT	get_assign_account_resources;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_person IN c_get_person LOOP
     idx := idx + 1;
     iex_debug_pub.logmessage ('idx= ' || idx);
     iex_debug_pub.logmessage ('r_person.salesforce_id = ' || r_person.resource_id);
	  x_resource_tab(idx).resource_id := r_person.resource_id;
	  x_resource_tab(idx).person_id := r_person.employee_id;
  End LOOP;*/

  --use bulk collect for performance as per kasreeni's request
  --jsanju 04/13/2004
  /*
    OPEN c_get_person ;
    FETCH c_get_person BULK COLLECT INTO x_resource_tab;
    CLOSE c_get_person;
  */


  -- Standard check of p_commit
 /* IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     iex_debug_pub.logmessage ('**** END get_access_resources ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO get_assign_account_resources;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_assign_account_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO get_assign_account_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_assign_account_resources;

PROCEDURE get_case_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_party_id         IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS
--Territory Assignment Changes
  CURSOR c_get_person IS
    SELECT ac.employee_id, ac.resource_id, count(cas_id)
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_cases_vl wi,ar_collectors ac
    WHERE hp.party_id = p_party_id
      and rs.resource_id = ac.resource_id
      and hp.collector_id = ac.collector_id
      and ac.resource_id = wi.owner_resource_id(+)
      and rs.user_id is not null
      and    ac.employee_id is not null
      group by ac.resource_id, ac.employee_id ORDER BY 3;*/

/*
  CURSOR c_get_person IS
    SELECT DISTINCT person_id, salesforce_id
    FROM  as_accesses acc
    WHERE acc.customer_id = p_party_id;
*/

/*  l_api_version   CONSTANT NUMBER       := p_api_version;
  l_api_name CONSTANT VARCHAR2(100) := 'GET_CASE_RESOURCES';
  l_init_msg_list CONSTANT VARCHAR2(1)  := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
BEGIN

     iex_debug_pub.logmessage ('**** BEGIN get_case_resources ************');
     iex_debug_pub.logmessage ('get_person cursor = ' ||
     'SELECT ac.employee_id, ac.resource_id, count(cas_id)
      FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_cases_vl wi,ar_collectors ac
      WHERE hp.party_id = p_party_id
      and rs.resource_id = ac.resource_id
      and hp.collector_id = ac.collector_id
      and ac.resource_id = wi.owner_resource_id(+)
      and rs.user_id is not null
      group by ac.resource_id, ac.employee_id ORDER BY 3');

  SAVEPOINT	get_case_resources;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_person IN c_get_person LOOP
     idx := idx + 1;
     iex_debug_pub.logmessage ('idx= ' || idx);
     iex_debug_pub.logmessage ('r_person.salesforce_id = ' || r_person.resource_id);
	  x_resource_tab(idx).resource_id := r_person.resource_id;
	  x_resource_tab(idx).person_id := r_person.employee_id;
  End LOOP;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     iex_debug_pub.logmessage ('**** END get_case_resources ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO get_case_resources;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_case_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO get_case_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_case_resources;*/
--End bug#5373412 schekuri 10-Jul-2006



/*
|| Overview:   builds a dynamic where clause based on name / condition / value array
||
|| Parameter:  array of name / condition / value like
||            'PARTY_NAME', '=', 'Anna Kournikova'
||            'AMOUNT_OVERDUE', '>=', '5000'
||
|| Return value: String with "Where party_name = 'Anna Kournikova' AND
||                                  amount_overdue >= 5000"
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| Creation date:  01/28/2003 5:53PM
||
|| Major Modifications: when              who                       what
||                      01/28/2003 5:53PM raverma                created
*/
function buildWhereClause(P_CONDITIONS IN IEX_UTILITIES.Condition_TBL) return VARCHAR2
IS

l_conditions IEX_UTILITIES.Condition_TBL;
l_return     VARCHAR2(5000);
l_count      NUMBER := 0;

--clchang updated for sql bind var 05/07/2003
vstr  varchar2(10);

Begin
l_conditions := p_conditions;
l_count      := 0;
vstr   := 'WHERE ';

     for J in 1..P_CONDITIONS.COUNT
     loop

         if J <> P_CONDITIONS.COUNT then
            l_return := l_return || P_CONDITIONS(J).COL_NAME || ' ' || P_CONDITIONS(J).CONDITION || ' ' || P_CONDITIONS(J).VALUE || ' AND ';
         else
            l_return := l_return || P_CONDITIONS(J).COL_NAME || ' ' || P_CONDITIONS(J).CONDITION || ' ' || P_CONDITIONS(J).VALUE;
         end if;
     --dbms_output.put_line(l_return);
     end loop;

     --clchang updated for sql bind var 05/07/2003
     -- return 'WHERE ' || l_return;
     return vstr ||l_return ;

End buildWhereClause;

-- Begin- Andre 07/28/2004 - Add bill to assignmnet

-- This procedure will return access to a bill to site use instead of site use id
-- this assumes use of the script to transfer collector from customer profiles
-- to as_accesses, this will place the site_use_id into the attribute1 column
--Begin bug#5373412 schekuri 10-Jul-2006
--Removed the following procedures and added a single consolidate procedure get_assigned_collector
/*PROCEDURE get_billto_resources(p_api_version      IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               p_site_use_id      IN  VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS


--Territory Assignment Changes
/*  CURSOR c_get_person IS
   (
    SELECT ac.employee_id, ac.resource_id
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs,
           ar_collectors ac
    WHERE hp.site_use_id    = p_site_use_id
      and rs.resource_id    = ac.resource_id
      and hp.collector_id   = ac.collector_id
      and rs.user_id is not null
      and    ac.employee_id is not null
      group by ac.resource_id, ac.employee_id
    union all
    SELECT ac.employee_id, ac.resource_id, 0
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs,ar_collectors ac
    WHERE hp.site_use_id = p_site_use_id
      and rs.resource_id = ac.resource_id
      and hp.collector_id = ac.collector_id
      and rs.user_id is not null and
      not exists (select null from iex_strategy_work_items wi
            where ac.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and    ac.employee_id is not null
       group by ac.resource_id, ac.employee_id
      ) order by 3;
*/
/* We use hz_customer_profiles and
   Load balancing when the assigned with Group Resource
*/
/*CURSOR c_get_person is
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.site_use_id = p_site_use_id
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.site_use_id  = p_site_use_id
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.site_use_id  = p_site_use_id
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
       group by jtg.resource_id, jtg.person_id
      ) order by 3;


  l_api_version   CONSTANT NUMBER       := p_api_version;
  l_api_name CONSTANT VARCHAR2(100) := 'GET_BILLTO_RESOURCES';
  l_init_msg_list CONSTANT VARCHAR2(1)  := p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
BEGIN

     iex_debug_pub.logmessage ('**** BEGIN on all
      get_billto_resources ************');
     iex_debug_pub.logmessage ('get_person cursor = ' ||
      ' SELECT ac.employee_id, ac.resource_id, count(work_item_id)
       FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_strategy_work_items wi,ar_collectors ac
       WHERE hp.site_use_id    = p_site_use_id
       and rs.resource_id    = ac.resource_id
       and ac.resource_id    = wi.resource_id
       and hp.collector_id   = ac.collector_id
       and wi.status_code    = OPEN
       and rs.user_id is not null
       group by ac.resource_id, ac.employee_id');


  SAVEPOINT	get_assign_resources;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR r_person IN c_get_person LOOP
     idx := idx + 1;
     iex_debug_pub.logmessage ('idx= ' || idx);
     iex_debug_pub.logmessage ('r_person.salesforce_id = ' || r_person.resource_id);
	  x_resource_tab(idx).resource_id := r_person.resource_id;
	  x_resource_tab(idx).person_id := r_person.employee_id;
  End LOOP;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     iex_debug_pub.logmessage ('**** END get_billto_resources ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
        ROLLBACK TO get_assign_resources;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_billto_resources;*/
-- End- Andre 07/28/2004 - Add bill to assignmnet
--End bug#5373412 schekuri 10-Jul-2006


-- Begin- Andre 09/15/2004 - Function to get lookup meaning - performance enhancement as per Ramakant Alat
FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_meaning iex_lookups_v.meaning%TYPE;
l_hash_value NUMBER;
BEGIN
  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_lookup_code,
                                         1000,
                                         25000);

    IF pg_lookups_rec.EXISTS(l_hash_value) THEN
        l_meaning := pg_lookups_rec(l_hash_value);
    ELSE

     SELECT meaning
     INTO   l_meaning
     FROM   iex_lookups_v
     WHERE  lookup_type = p_lookup_type
      AND  lookup_code = p_lookup_code ;

     pg_lookups_rec(l_hash_value) := l_meaning;

    END IF;

  END IF;

  return(l_meaning);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;
-- End- Andre 09/15/2004 - Function to get lookup meaning - performance enhancement as per Ramakant Alat

PROCEDURE put_param_value (p_param_value  IN VARCHAR2,
                          p_param_key  OUT NOCOPY NUMBER) IS
l_hash_value NUMBER;
BEGIN
  IF p_param_value IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_param_value,
                                         1000,
                                         25000);

    IF pg_param_tab.EXISTS(l_hash_value) THEN
        p_param_key := l_hash_value;
    ELSE
        pg_param_tab(l_hash_value) := p_param_value;
        p_param_key := l_hash_value;

    END IF;

  END IF;
END;


PROCEDURE get_param_value(p_param_key IN NUMBER,
                          p_param_value OUT NOCOPY VARCHAR2) IS
BEGIN
  IF pg_param_tab.EXISTS(p_param_key) THEN
    p_param_value := pg_param_tab(p_param_key);
  ELSE
    p_param_value := 'N/A';
  END IF;
END;


PROCEDURE delete_param_value(p_param_key IN NUMBER) IS
BEGIN
  IF pg_param_tab.EXISTS(p_param_key) THEN
    pg_param_tab.DELETE(p_param_key);
  ELSE
    NULL;
  END IF;
END;

/*
   Overview : Check if the dunning letter flag before send out a dunning letter.
              It checks the billto level first then account level; at last customer level.
   Parameter: p_party_id:  if customer level then pass the party_id
              p_cust_account_id : if account level then pass the cust_account_id
              p_site_use_id : if bill_to level then pass the customer_site_use_id
              p_delinquency_id : if delinquency level then pass the delinquency_id
   Return:  'Y' if ok to send dunning letter
            'N' if no dunning letter should be sent
   creation date: 06/02/2004
   author:  ctlee
*/
FUNCTION DunningProfileCheck
(
  p_party_id             IN  number
  , p_cust_account_id    IN  number
  , p_site_use_id        IN  number
  , p_delinquency_id     IN  number
)
return varchar2
IS
    l_dunning_letters varchar2(10);
    l_party_id number;
    l_cust_account_id number;
    l_site_use_id number;
    l_delinquency_id number;

    CURSOR get_party_account_id_cur (p_customer_site_use_id number) is
        SELECT  ca.party_id party_id, ca.cust_account_id cust_account_id
              FROM hz_cust_site_uses site_uses, hz_cust_acct_sites acct_sites, hz_cust_accounts ca
              WHERE site_uses.site_use_id = p_customer_site_use_id
              AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id
              AND ca.cust_account_id = acct_sites.cust_account_id;

    cursor c_billto (p_site_use_id number) is
      select dunning_letters from hz_customer_profiles
      where site_use_id = p_site_use_id and status = 'A';

    CURSOR get_party_id_cur (p_cust_account_id number) is
        SELECT party_id  FROM HZ_CUST_ACCOUNTS
            WHERE cust_account_id = p_cust_account_id ;

    cursor c_account (p_cust_account_id number) is
      select dunning_letters from hz_customer_profiles
      where cust_account_id = p_cust_account_id and status = 'A' and site_use_id is null;

    cursor c_party (p_party_id number) is
      select dunning_letters from hz_customer_profiles
      -- begin bug 4587842 ctlee 09/06/2005
      where party_id = p_party_id and status = 'A'
      and site_use_id is null;
      -- where party_id = p_party_id and status = 'A' and site_use_id is null and cust_account_id is null;
      -- end bug 4587842 ctlee 09/06/2005

    cursor c_get_billto (p_delinquency_id number) is
      select customer_site_use_id from iex_delinquencies_all
      where delinquency_id = p_delinquency_id;
BEGIN

    l_party_id  := p_party_id;
    l_cust_account_id  := p_cust_account_id;
    l_site_use_id  := p_site_use_id;
    l_delinquency_id  := p_delinquency_id;

    -- default to no dunning letter to send, if there is no record that match
    l_dunning_letters := 'Y';

    -- get bill_to id to check, because there is no delinquency level in customer_profile
    if (l_delinquency_id is not null) Then
      OPEN c_get_billto (l_delinquency_id);
      FETCH c_get_billto INTO l_site_use_id;
      CLOSE c_get_billto;
    end if;

    if (l_site_use_id is not null) Then
      -- set up accout and party id in case there is no record for this bill to
      OPEN get_party_account_id_cur (l_site_use_id);
      FETCH get_party_account_id_cur INTO l_party_id, l_cust_account_id;
      CLOSE get_party_account_id_cur;

      open c_billto(l_site_use_id);
      loop
        fetch c_billto into l_dunning_letters;
        if c_billto%notfound then
           exit;
        else
	   -- Commented the if condition for Bug#6649352 bibeura 12-Dec-2007
           -- if l_dunning_letters = 'N' then
             return l_dunning_letters;
           -- end if;
        end if;
      end loop;
      close c_billto;
    end if;

    if (l_cust_account_id is not null) Then
      -- set up party id in case there is no record for this account to
      OPEN get_party_id_cur (l_cust_account_id);
      FETCH get_party_id_cur INTO l_party_id;
      CLOSE get_party_id_cur;

      open c_account(l_cust_account_id);
      loop
        fetch c_account into l_dunning_letters;
        if c_account%notfound then
           exit;
        else
    	--Bug5348445. Fix By LKKUMAR on 21-Jun-2006. Start.
	--   if l_dunning_letters = 'N' then
             return l_dunning_letters;
	--   end if;
    	--Bug5348445. Fix By LKKUMAR on 21-Jun-2006. End.
        end if;
      end loop;
      close c_account;
    end if;

    if (l_party_id is not null) Then
      open c_party(l_party_id);
      loop
        fetch c_party into l_dunning_letters;
        if c_party%notfound then
           exit;
        else
	   -- Commented the if condition for Bug#6649352 bibeura 12-Dec-2007
           -- if l_dunning_letters = 'N' then
             return l_dunning_letters;
           -- end if;
        end if;
      end loop;
      close c_party;
    end if;

    return l_dunning_letters;

EXCEPTION
 WHEN OTHERS THEN
    return l_dunning_letters;
END DunningProfileCheck;



/*
    Overview: This function is to determine if the required min_dunning and min_invoice_dunning amount are
              met before sending the dunning letter.
   Parameter: p_cust_account_id : if account level then pass the cust_account_id
              p_site_use_id : if bill_to level then pass the customer_site_use_id
   Return:  'Y' if ok to send dunning letter
            'N' if no dunning letter should be sent
   creation date: 06/02/2004
   author:  ctlee
   Note: it is not available in the customer and delinquency level
 */
FUNCTION DunningMinAmountCheck
(
  p_cust_account_id    IN  number
  , p_site_use_id        IN  number
)
return varchar2
IS
    l_dunning_letters varchar2(10);
    l_cust_account_id number;
    l_site_use_id  number;
    l_min_dunning_amount number;
    l_min_dunning_invoice_amount number;
    l_min_currency_code varchar2(15);

    l_rate_type varchar2(100);
    l_amount number;
    l_invoice_amount number;
    l_convert_amount number;
    l_amount_due_remaining number;
    l_invoice_currency_code varchar2(15);
    l_class varchar2(20);

    -- there is no status to check if active or not,
    -- field expiration_date is null only - not used
    -- because there is more than 1 record for the same site_use_id, so we pick the functional currency one
    cursor c_billto (p_customer_site_use_id number) is
      select currency_code, nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0) from hz_cust_profile_amts
        where site_use_id = p_customer_site_use_id and currency_code = (
          SELECT  sob.currency_code FROM ar_system_parameters sp, gl_sets_of_books sob
          WHERE   sob.set_of_books_id = sp.set_of_books_id);

    -- only open status
    cursor c_amount_billto (p_site_use_id number) is
      select nvl(a.amount_due_remaining, 0), a.invoice_currency_code, class
        from ar_payment_schedules_all a, iex_delinquencies_all b     --Changed to ar_payment_schedules_all for bug#5652343 by gnramasa on 07-Mar-2007
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id;

    cursor c_account (p_cust_account_id number) is
      select currency_code, nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
      from hz_cust_profile_amts
      where cust_account_id = p_cust_account_id and currency_code = (
          SELECT  sob.currency_code FROM ar_system_parameters sp, gl_sets_of_books sob
          WHERE   sob.set_of_books_id = sp.set_of_books_id);

    -- only open status
    cursor c_amount_account (p_cust_account_id number) is
      select nvl(a.amount_due_remaining,0), a.invoice_currency_code, class
        from ar_payment_schedules_all a, iex_delinquencies_all b   --Changed to ar_payment_schedules_all for bug#5652343 by gnramasa on 07-Mar-2007
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id;

	--Start bug 7026222 gnramasa 20th July 08
	l_check_dunn_profile	varchar2(10);
	l_tot_amt_due_rem       number;

	cursor c_billto_dist_inv_cur (p_site_use_id number) is
	select distinct a.invoice_currency_code
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id
	order by 1;

	cursor c_billto_min_dunn_amt (p_site_use_id number, p_currency_code varchar) is
	select nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
	from hz_cust_profile_amts
	where site_use_id = p_site_use_id
	and currency_code = p_currency_code;

	cursor c_billto_tot_amt_due_rem (p_site_use_id number, p_currency_code varchar, p_min_dun_inv_amt number) is
	select sum(nvl(a.amount_due_remaining,0))
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id
        and a.invoice_currency_code = p_currency_code
        and a.amount_due_remaining >= p_min_dun_inv_amt;

	cursor c_acc_dist_inv_cur (p_cust_account_id number) is
	select distinct a.invoice_currency_code
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id
	order by 1;

	cursor c_acc_min_dunn_amt (p_cust_account_id number, p_currency_code varchar) is
	select nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
	from hz_cust_profile_amts
	where cust_account_id = p_cust_account_id
	and currency_code = p_currency_code
	and site_use_id is null;

	cursor c_acc_tot_amt_due_rem (p_cust_account_id number, p_currency_code varchar, p_min_dun_inv_amt number) is
	select sum(nvl(a.amount_due_remaining,0))
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id
        and a.invoice_currency_code = p_currency_code
        and a.amount_due_remaining >= p_min_dun_inv_amt;

	--End bug 7026222 gnramasa 20th July 08
BEGIN

    -- default to no dunning letter to send
    l_dunning_letters := 'Y';
    l_amount  := 0 ;
    l_invoice_amount  := 0 ;
    l_convert_amount  := 0 ;
    l_amount_due_remaining  := 0 ;

    l_cust_account_id := p_cust_account_id;
    l_site_use_id   := p_site_use_id;
    l_min_dunning_amount  := 0;
    l_min_dunning_invoice_amount  := 0;

    l_rate_type :=  nvl(fnd_profile.value('IEX_COLLECTIONS_RATE_TYPE'), 'Corporate');

    --Start bug 7026222 gnramasa 20th July 08
    l_check_dunn_profile := nvl(fnd_profile.value('IEX_CHK_DUNN_AT_FUNC_CURR'), 'Y');
    --If the profile 'IEX: Check Dunning amount at function currency' is set to 'Yes' then the current functionality will continue
    --and if the profile is set to 'No' then we can check amount at currency level. By default the profile value is 'Yes'
    if l_check_dunn_profile = 'Y' then
	    -- determine the min dunning and min dunning invoice amount first
	    if (l_site_use_id is not null) Then

	      open c_billto(l_site_use_id);
	      fetch c_billto into l_min_currency_code, l_min_dunning_amount, l_min_dunning_invoice_amount;
	      close c_billto;

	    elsif  (l_cust_account_id is not null ) Then
	      -- no need to set up party id because there is no party level record in hz_cust_profile_amts
	      open c_account(l_cust_account_id);
	      fetch c_account into l_min_currency_code, l_min_dunning_amount, l_min_dunning_invoice_amount;
	      close c_account;
	    end if;

	    -- no amout record to check
	    if (l_min_currency_code is null) then
	      return l_dunning_letters;
	    end if;

	    l_amount := 0;
	    l_invoice_amount := 0;

	    -- get the delinquency amount and convert it to the profile currency code
	    -- do it line by line because each line may have different currency code
	    if (l_site_use_id is not null) Then
	      open c_amount_billto(l_site_use_id);
	      loop
		fetch c_amount_billto into l_amount_due_remaining, l_invoice_currency_code, l_class;
		if c_amount_billto%notfound then
		  exit;
		end if;
		if (l_invoice_currency_code <> l_min_currency_code) then
		  l_convert_amount := gl_currency_api.convert_amount(
		     x_from_currency => l_invoice_currency_code
		     ,x_to_currency => l_min_currency_code
		     ,x_conversion_date => sysdate
		     ,x_conversion_type => l_rate_type
		     ,x_amount => l_amount_due_remaining);
		  l_amount := l_amount + l_convert_amount;
		  -- also calculate the invoice amount
		  if (l_class = 'INV') then
		    l_invoice_amount := l_invoice_amount + l_convert_amount;
		  end if;
		else
		  l_amount := l_amount + l_amount_due_remaining;
		  -- also calculate the invoice amount
		  if (l_class = 'INV') then
		    l_invoice_amount := l_invoice_amount + l_amount_due_remaining;
		  end if;
		end if;
	      end loop;
	      close c_amount_billto;
	    elsif  (l_cust_account_id is not null ) Then   -- account level calculation
	      open c_amount_account(l_cust_account_id);
	      loop
		fetch c_amount_account into l_amount_due_remaining, l_invoice_currency_code, l_class;
		if c_amount_account%notfound then
		  exit;
		end if;
		if (l_invoice_currency_code <> l_min_currency_code) then
		  l_convert_amount := gl_currency_api.convert_amount(
		     x_from_currency => l_invoice_currency_code
		     ,x_to_currency => l_min_currency_code
		     ,x_conversion_date => sysdate
		     ,x_conversion_type => l_rate_type
		     ,x_amount => l_amount_due_remaining);
		  l_amount := l_amount + l_convert_amount;
		  -- also calculate the invoice amount
		  if (l_class = 'INV') then
		    l_invoice_amount := l_invoice_amount + l_convert_amount;
		  end if;
		else
		  l_amount := l_amount + l_amount_due_remaining;
		  -- also calculate the invoice amount
		  if (l_class = 'INV') then
		    l_invoice_amount := l_invoice_amount + l_amount_due_remaining;
		  end if;
		end if;
	      end loop;
	      close c_amount_account;

	    end if;

	    -- determine the flag
	    if (l_amount < l_min_dunning_amount or l_invoice_amount < l_min_dunning_invoice_amount) then
	      l_dunning_letters := 'N';
	    end if;
    else

	if (l_site_use_id is not null) Then
	      l_dunning_letters := 'N';  --initially set it no
	      open c_billto_dist_inv_cur(l_site_use_id);
	      loop
		fetch c_billto_dist_inv_cur into l_invoice_currency_code;
		if c_billto_dist_inv_cur%notfound then
		  exit;
		end if;

		open c_billto_min_dunn_amt (l_site_use_id, l_invoice_currency_code);
		fetch c_billto_min_dunn_amt into l_min_dunning_amount, l_min_dunning_invoice_amount;
		close c_billto_min_dunn_amt;

		if l_min_dunning_amount is null then
			l_min_dunning_amount := 0;
		end if;

		if l_min_dunning_invoice_amount is null then
			l_min_dunning_invoice_amount := 0;
		end if;

		open c_billto_tot_amt_due_rem (l_site_use_id, l_invoice_currency_code, l_min_dunning_invoice_amount);
		fetch c_billto_tot_amt_due_rem into l_tot_amt_due_rem;
		close c_billto_tot_amt_due_rem;

		--If any currency group satisfies the condition then we have to send the dunning letter,
		--so no need to check for other currencies.
		if l_tot_amt_due_rem >= l_min_dunning_amount then
			l_dunning_letters := 'Y';
			exit;
		end if;
	      end loop;
	      close c_billto_dist_inv_cur;
	elsif (l_cust_account_id is not null ) Then   -- account level calculation
	      l_dunning_letters := 'N';  --initially set it no
	      open c_acc_dist_inv_cur(l_cust_account_id);
	      loop
		fetch c_acc_dist_inv_cur into l_invoice_currency_code;
		if c_acc_dist_inv_cur%notfound then
		  exit;
		end if;

		open c_acc_min_dunn_amt (l_cust_account_id, l_invoice_currency_code);
		fetch c_acc_min_dunn_amt into l_min_dunning_amount, l_min_dunning_invoice_amount;
		close c_acc_min_dunn_amt;

		if l_min_dunning_amount is null then
			l_min_dunning_amount := 0;
		end if;

		if l_min_dunning_invoice_amount is null then
			l_min_dunning_invoice_amount := 0;
		end if;

		open c_acc_tot_amt_due_rem (l_cust_account_id, l_invoice_currency_code, l_min_dunning_invoice_amount);
		fetch c_acc_tot_amt_due_rem into l_tot_amt_due_rem;
		close c_acc_tot_amt_due_rem;

		--If any currency group satisfies the condition then we have to send the dunning letter,
		--so no need to check for other currencies.
		if l_tot_amt_due_rem >= l_min_dunning_amount then
			l_dunning_letters := 'Y';
			exit;
		end if;
	      end loop;
	      close c_acc_dist_inv_cur;
	end if;
    end if;  --if l_check_dunn_profile = 'Y' then

--End bug 7026222 gnramasa 20th July 08

    return l_dunning_letters;
EXCEPTION
 WHEN OTHERS THEN
    return l_dunning_letters;
End DunningMinAmountCheck;

/*
    Overview: This function is to determine if the required min_dunning and min_invoice_dunning amount are
              met before sending the dunning letter.
   Parameter: p_cust_account_id : if account level then pass the cust_account_id
              p_site_use_id : if bill_to level then pass the customer_site_use_id
   Return:  'Y' if ok to send dunning letter
            'N' if no dunning letter should be sent
   creation date: 11th Dec 09
   author:  gnramasa
   Note: it is not available in the customer and delinquency level
 */
Procedure StagedDunningMinAmountCheck
(
  p_cust_account_id         IN number
  , p_site_use_id           IN number
  , p_party_id              IN number
  , p_dunning_plan_id       IN number
  , p_grace_days            IN number
  , p_dun_disputed_items    IN VARCHAR2
  , p_correspondence_date   IN DATE
  , p_running_level         IN VARCHAR2
  , p_inc_inv_curr          OUT NOCOPY INC_INV_CURR_TBL
  , p_dunning_letters       OUT NOCOPY varchar2
)

IS
    l_dunning_letters varchar2(10);
    l_cust_account_id number;
    l_site_use_id  number;
    l_party_id     number;
    l_min_dunning_amount number;
    l_min_dunning_invoice_amount number;
    l_min_currency_code varchar2(15);

    l_rate_type varchar2(100);
    l_invoice_amount number;
    l_convert_amount number;
    l_amount_due_remaining number;
    l_invoice_currency_code varchar2(15);
    l_class varchar2(20);

    -- there is no status to check if active or not,
    -- field expiration_date is null only - not used
    -- because there is more than 1 record for the same site_use_id, so we pick the functional currency one
    cursor c_billto (p_customer_site_use_id number) is
      select currency_code, nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0) from hz_cust_profile_amts
        where site_use_id = p_customer_site_use_id and currency_code = (
          SELECT  sob.currency_code FROM ar_system_parameters sp, gl_sets_of_books sob
          WHERE   sob.set_of_books_id = sp.set_of_books_id);

    -- only open status
    cursor c_amount_billto (p_site_use_id number) is
      select nvl(a.amount_due_remaining, 0), a.invoice_currency_code, class
        from ar_payment_schedules_all a, iex_delinquencies_all b     --Changed to ar_payment_schedules_all for bug#5652343 by gnramasa on 07-Mar-2007
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id;

    cursor c_account (p_cust_account_id number) is
      select currency_code, nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
      from hz_cust_profile_amts
      where cust_account_id = p_cust_account_id and currency_code = (
          SELECT  sob.currency_code FROM ar_system_parameters sp, gl_sets_of_books sob
          WHERE   sob.set_of_books_id = sp.set_of_books_id);

    -- only open status
    cursor c_amount_account (p_cust_account_id number) is
      select nvl(a.amount_due_remaining,0), a.invoice_currency_code, class
        from ar_payment_schedules_all a, iex_delinquencies_all b   --Changed to ar_payment_schedules_all for bug#5652343 by gnramasa on 07-Mar-2007
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id;

	--Start bug 7026222 gnramasa 20th July 08
	l_check_dunn_profile	varchar2(10);
	l_tot_amt_due_rem       number;

	cursor c_billto_dist_inv_cur (p_site_use_id number) is
	select distinct a.invoice_currency_code
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        --and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id
	order by 1;

	cursor c_billto_min_dunn_amt (p_site_use_id number, p_currency_code varchar) is
	select nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
	from hz_cust_profile_amts
	where site_use_id = p_site_use_id
	and currency_code = p_currency_code;

	cursor c_billto_tot_amt_due_rem (p_site_use_id number, p_currency_code varchar, p_min_dun_inv_amt number) is
	select sum(nvl(a.amount_due_remaining,0))
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.customer_site_use_id = p_site_use_id
        and a.invoice_currency_code = p_currency_code
        and a.amount_due_remaining >= p_min_dun_inv_amt;

	cursor c_acc_dist_inv_cur (p_cust_account_id number) is
	select distinct a.invoice_currency_code
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        --and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id
	order by 1;

	cursor c_cus_dist_inv_cur (p_party_id number) is
	select distinct a.invoice_currency_code
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        --and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.party_cust_id = p_party_id
	order by 1;

	cursor c_acc_min_dunn_amt (p_cust_account_id number, p_currency_code varchar) is
	select nvl(min_dunning_amount,0), nvl(min_dunning_invoice_amount,0)
	from hz_cust_profile_amts
	where cust_account_id = p_cust_account_id
	and currency_code = p_currency_code
	and site_use_id is null;

	cursor c_acc_tot_amt_due_rem (p_cust_account_id number, p_currency_code varchar, p_min_dun_inv_amt number) is
	select sum(nvl(a.amount_due_remaining,0))
        from ar_payment_schedules_all a, iex_delinquencies_all b
        where a.payment_schedule_id = b.payment_schedule_id
        and b.status in ('DELINQUENT', 'PREDELINQUENT')
	AND   a.class IN ('INV', 'GUAR', 'CB', 'DM', 'DEP')
        and a.status = 'OP'
        and b.cust_account_id = p_cust_account_id
        and a.invoice_currency_code = p_currency_code
        and a.amount_due_remaining >= p_min_dun_inv_amt;

	--End bug 7026222 gnramasa 20th July 08

	cursor c_dunningplan_lines(p_dunn_plan_id number) is
	    select ag_dn_xref_id,
		   dunning_level,
		   template_id,
		   xdo_template_id,
		   fm_method,
		   upper(callback_flag) callback_flag,
		   callback_days,
		   range_of_dunning_level_from,
		   range_of_dunning_level_to,
		   min_days_between_dunning
	    from iex_ag_dn_xref
	    where dunning_plan_id = p_dunn_plan_id
	    order by AG_DN_XREF_ID;

	l_dunningplan_lines	    c_dunningplan_lines%rowtype;
	l_amount                    number;
	i                           number := 0;
	l_stage                     number;
	l_api_name                  varchar2(100);

--	l_inc_inv_curr              IEX_UTILITIES.INC_INV_CURR_TBL;

	cursor c_bill_dunning_trx_null_dun_ct (p_site_use_id number, p_min_days_bw_dun number,
                                          p_corr_date date, p_grace_days number, p_include_dis_items varchar,
					  p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.customer_site_use_id = p_site_use_id
	    and del.staged_dunning_level is NULL
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status = 'CURRENT'
	    and del.customer_site_use_id = p_site_use_id
	    and del.staged_dunning_level is NULL
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    );

	    cursor c_bill_dunning_trx_ct (p_site_use_id number, p_stage_no number,
					 p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar,
					 p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.customer_site_use_id = p_site_use_id
	    and del.staged_dunning_level = p_stage_no
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and nvl(
		     (
			(select trunc(correspondence_date) from iex_dunnings
			 where dunning_id =
			    (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
			                                         iex_dunnings dunn
			     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
			     and dunn.dunning_id = iet.dunning_id
			     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
						OR (dunn.dunning_mode = 'FINAL'))
			     and iet.STAGE_NUMBER = p_stage_no
			     and dunn.delivery_status is null
			  --   group by iet.dunning_id  bug 9508149
			    )
			 )
		       + p_min_days_bw_dun
		      )
		     , p_corr_date
		    )
		    <= p_corr_date
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status = 'CURRENT'
	    and del.customer_site_use_id = p_site_use_id
	    and del.staged_dunning_level = p_stage_no
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and nvl(
		(
		 (select trunc(correspondence_date) from iex_dunnings
		  where dunning_id =
		   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
							 iex_dunnings dunn
		     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
		     and dunn.dunning_id = iet.dunning_id
		     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
					OR (dunn.dunning_mode = 'FINAL'))
		     and iet.STAGE_NUMBER = p_stage_no
		     and dunn.delivery_status is null
		   --  group by iet.dunning_id  bug 9508149
		     ))
		    + p_min_days_bw_dun )
		    , p_corr_date )
		    <= p_corr_date
	     and arp.invoice_currency_code = p_currency_code
             and arp.amount_due_remaining >= p_min_dun_inv_amt
	     );

	     cursor c_acc_dunning_trx_null_dun_ct (p_cust_acct_id number, p_min_days_bw_dun number,
                                          p_corr_date date, p_grace_days number, p_include_dis_items varchar,
					  p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.cust_account_id = p_cust_acct_id
	    and del.staged_dunning_level is NULL
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status = 'CURRENT'
	    and del.cust_account_id = p_cust_acct_id
	    and del.staged_dunning_level is NULL
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    );

	    cursor c_acc_dunning_trx_ct (p_cust_acct_id number, p_stage_no number,
					 p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar,
					 p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.cust_account_id = p_cust_acct_id
	    and del.staged_dunning_level = p_stage_no
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and nvl(
		     (
			(select trunc(correspondence_date) from iex_dunnings
			 where dunning_id =
			    (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
			                                         iex_dunnings dunn
			     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
			     and dunn.dunning_id = iet.dunning_id
			     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
						OR (dunn.dunning_mode = 'FINAL'))
			     and iet.STAGE_NUMBER = p_stage_no
			     and dunn.delivery_status is null
			--     group by iet.dunning_id  bug 9508149
			    )
			 )
		       + p_min_days_bw_dun
		      )
		     , p_corr_date
		    )
		    <= p_corr_date
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status = 'CURRENT'
	    and del.cust_account_id = p_cust_acct_id
	    and del.staged_dunning_level = p_stage_no
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and nvl(
		(
		 (select trunc(correspondence_date) from iex_dunnings
		  where dunning_id =
		   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
							 iex_dunnings dunn
		     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
		     and dunn.dunning_id = iet.dunning_id
		     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
					OR (dunn.dunning_mode = 'FINAL'))
		     and iet.STAGE_NUMBER = p_stage_no
		     and dunn.delivery_status is null
		   --  group by iet.dunning_id  bug 9508149
		     ))
		    + p_min_days_bw_dun )
		    , p_corr_date )
		    <= p_corr_date
	     and arp.invoice_currency_code = p_currency_code
             and arp.amount_due_remaining >= p_min_dun_inv_amt
	     );

	   cursor c_cus_dunning_trx_null_dun_ct (p_party_id number, p_min_days_bw_dun number,
                                          p_corr_date date, p_grace_days number, p_include_dis_items varchar,
					  p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.party_cust_id = p_party_id
	    and del.staged_dunning_level is NULL
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del,
		 ar_payment_schedules arp
	    where del.payment_schedule_id = arp.payment_schedule_id
	    and del.status = 'CURRENT'
	    and del.party_cust_id = p_party_id
	    and del.staged_dunning_level is NULL
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and (trunc(arp.due_date) + p_min_days_bw_dun) <= p_corr_date
	    and (trunc(arp.due_date) + p_grace_days) <= p_corr_date
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    );

	    cursor c_cus_dunning_trx_ct (p_party_id number, p_stage_no number,
					 p_min_days_bw_dun number, p_corr_date date, p_include_dis_items varchar,
					 p_currency_code varchar, p_min_dun_inv_amt number) is
	    select nvl(sum(amount_due_remaining),0) from (
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status in ('DELINQUENT','PREDELINQUENT')
	    and del.party_cust_id = p_party_id
	    and del.staged_dunning_level = p_stage_no
	    and nvl(arp.amount_in_dispute,0) = decode(p_include_dis_items, 'Y', nvl(arp.amount_in_dispute,0), 0)
	    and nvl(
		     (
			(select trunc(correspondence_date) from iex_dunnings
			 where dunning_id =
			    (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
			                                         iex_dunnings dunn
			     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
			     and dunn.dunning_id = iet.dunning_id
			     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
						OR (dunn.dunning_mode = 'FINAL'))
			     and iet.STAGE_NUMBER = p_stage_no
			     and dunn.delivery_status is null
			  --   group by iet.dunning_id  bug 9508149
			    )
			 )
		       + p_min_days_bw_dun
		      )
		     , p_corr_date
		    )
		    <= p_corr_date
	    and arp.invoice_currency_code = p_currency_code
            and arp.amount_due_remaining >= p_min_dun_inv_amt
	    union
	    select arp.amount_due_remaining amount_due_remaining
	    from iex_delinquencies del
		 ,ar_payment_schedules arp
	    where
	    del.payment_schedule_id = arp.payment_schedule_id and
	    del.status = 'CURRENT'
	    and del.party_cust_id = p_party_id
	    and del.staged_dunning_level = p_stage_no
	    and arp.status = 'OP'
	    and arp.class = 'INV'
	    and arp.amount_in_dispute >= decode(p_include_dis_items, 'Y', arp.amount_due_remaining, (arp.amount_due_original + 1))
	    and nvl(
		(
		 (select trunc(correspondence_date) from iex_dunnings
		  where dunning_id =
		   (select max(iet.DUNNING_ID) from iex_dunning_transactions iet,
							 iex_dunnings dunn
		     where iet.PAYMENT_SCHEDULE_ID = del.payment_schedule_id
		     and dunn.dunning_id = iet.dunning_id
		     and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
					OR (dunn.dunning_mode = 'FINAL'))
		     and iet.STAGE_NUMBER = p_stage_no
		     and dunn.delivery_status is null
		   --  group by iet.dunning_id bug 9508149
		     ))
		    + p_min_days_bw_dun )
		    , p_corr_date )
		    <= p_corr_date
	     and arp.invoice_currency_code = p_currency_code
             and arp.amount_due_remaining >= p_min_dun_inv_amt
	     );


BEGIN

    iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - Start');
    -- default to no dunning letter to send
    l_dunning_letters := 'Y';
    l_amount  := 0 ;
    l_invoice_amount  := 0 ;
    l_convert_amount  := 0 ;
    l_amount_due_remaining  := 0 ;

    l_cust_account_id := p_cust_account_id;
    l_site_use_id   := p_site_use_id;
    l_party_id := p_party_id;
    l_min_dunning_amount  := 0;
    l_min_dunning_invoice_amount  := 0;

    l_inc_inv_curr.delete;

    l_api_name	:= 'IEX_UTILITIES.StagedDunningMinAmountCheck';

    l_rate_type :=  nvl(fnd_profile.value('IEX_COLLECTIONS_RATE_TYPE'), 'Corporate');

    if (l_site_use_id is not null) Then
	      --l_dunning_letters := 'N';  --initially set it no

	      open c_billto_dist_inv_cur(l_site_use_id);
	      loop
		fetch c_billto_dist_inv_cur into l_invoice_currency_code;
		if c_billto_dist_inv_cur%notfound then
		  exit;
		end if;

		open c_billto_min_dunn_amt (l_site_use_id, l_invoice_currency_code);
		fetch c_billto_min_dunn_amt into l_min_dunning_amount, l_min_dunning_invoice_amount;
		close c_billto_min_dunn_amt;

		if l_min_dunning_amount is null then
			l_min_dunning_amount := 0;
		end if;

		if l_min_dunning_invoice_amount is null then
			l_min_dunning_invoice_amount := 0;
		end if;
		l_amount		:= 0;
		l_tot_amt_due_rem	:= 0;

		      open c_dunningplan_lines (p_dunning_plan_id);
			 loop
				 fetch c_dunningplan_lines into l_dunningplan_lines;
				 exit when c_dunningplan_lines%notfound;

				 for i in l_dunningplan_lines.range_of_dunning_level_from..l_dunningplan_lines.range_of_dunning_level_to
				      loop
						l_stage	:= i-1;
						iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_stage :'||l_stage);

						if i = 1 then
							open c_bill_dunning_trx_null_dun_ct (l_site_use_id,
							                            l_dunningplan_lines.min_days_between_dunning,
										    p_correspondence_date,
										    p_grace_days,
										    p_dun_disputed_items,
										    l_invoice_currency_code,
										    l_min_dunning_invoice_amount);
							 fetch c_bill_dunning_trx_null_dun_ct into l_amount;
							 close c_bill_dunning_trx_null_dun_ct;
						else

							 open c_bill_dunning_trx_ct (l_site_use_id,
										   l_stage,
										   l_dunningplan_lines.min_days_between_dunning,
										   p_correspondence_date,
										   p_dun_disputed_items,
										   l_invoice_currency_code,
										   l_min_dunning_invoice_amount);
							 fetch c_bill_dunning_trx_ct into l_amount;
							 close c_bill_dunning_trx_ct;
						end if;
						l_tot_amt_due_rem := l_tot_amt_due_rem + l_amount;
					end loop;
			end loop;
			close c_dunningplan_lines;



		--If any currency group satisfies the condition then we have to send the dunning letter,
		--so no need to check for other currencies.
		if l_tot_amt_due_rem >= l_min_dunning_amount then
			--l_dunning_letters := 'Y';
			i := i +1;
			l_inc_inv_curr (i) := l_invoice_currency_code;
		end if;
	      end loop;
	      close c_billto_dist_inv_cur;

	elsif (l_cust_account_id is not null ) Then   -- account level calculation
	      --l_dunning_letters := 'N';  --initially set it no
	      iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - p_running_level :'||p_running_level);
	      if p_running_level = 'ACCOUNT' then
		      open c_acc_dist_inv_cur(l_cust_account_id);
		      loop
			fetch c_acc_dist_inv_cur into l_invoice_currency_code;
			if c_acc_dist_inv_cur%notfound then
			  exit;
			end if;
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_invoice_currency_code :'||l_invoice_currency_code);

			open c_acc_min_dunn_amt (l_cust_account_id, l_invoice_currency_code);
			fetch c_acc_min_dunn_amt into l_min_dunning_amount, l_min_dunning_invoice_amount;
			/*
			if c_acc_dist_inv_cur%notfound then
				i := i +1;
				l_inc_inv_curr (i) := l_invoice_currency_code;
			end if;
			*/
			close c_acc_min_dunn_amt;
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_amount :'||l_min_dunning_amount);
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_invoice_amount :'||l_min_dunning_invoice_amount);

			if l_min_dunning_amount is null then
				l_min_dunning_amount := 0;
			end if;

			if l_min_dunning_invoice_amount is null then
				l_min_dunning_invoice_amount := 0;
			end if;

			l_amount		:= 0;
			l_tot_amt_due_rem	:= 0;

			      open c_dunningplan_lines (p_dunning_plan_id);
				 loop
					 fetch c_dunningplan_lines into l_dunningplan_lines;
					 exit when c_dunningplan_lines%notfound;

					 for i in l_dunningplan_lines.range_of_dunning_level_from..l_dunningplan_lines.range_of_dunning_level_to
					      loop
							WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - i: ' || i);
							l_stage	:= i-1;
							iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_stage :'||l_stage);

							if i = 1 then
								open c_acc_dunning_trx_null_dun_ct (l_cust_account_id,
											    l_dunningplan_lines.min_days_between_dunning,
											    p_correspondence_date,
											    p_grace_days,
											    p_dun_disputed_items,
											    l_invoice_currency_code,
											    l_min_dunning_invoice_amount);
								 fetch c_acc_dunning_trx_null_dun_ct into l_amount;
								 close c_acc_dunning_trx_null_dun_ct;
								 iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_amount: ' || l_amount);
							else

								 open c_acc_dunning_trx_ct (l_cust_account_id,
											   l_stage,
											   l_dunningplan_lines.min_days_between_dunning,
											   p_correspondence_date,
											   p_dun_disputed_items,
											   l_invoice_currency_code,
											   l_min_dunning_invoice_amount);
								 fetch c_acc_dunning_trx_ct into l_amount;
								 close c_acc_dunning_trx_ct;
								 iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_amount: ' || l_amount);
							end if;
							l_tot_amt_due_rem := l_tot_amt_due_rem + l_amount;
						end loop;
				end loop;
				close c_dunningplan_lines;



			--If any currency group satisfies the condition then we have to send the dunning letter,
			--so no need to check for other currencies.
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_tot_amt_due_rem: ' || l_tot_amt_due_rem);
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_amount: ' || l_min_dunning_amount);
			if l_tot_amt_due_rem >= l_min_dunning_amount then
				--l_dunning_letters := 'Y';
				i := i +1;
				l_inc_inv_curr (i) := l_invoice_currency_code;
			end if;
		      end loop;
		      close c_acc_dist_inv_cur;

		elsif p_running_level = 'CUSTOMER' then
			open c_cus_dist_inv_cur(l_party_id);
		      loop
			fetch c_cus_dist_inv_cur into l_invoice_currency_code;
			if c_cus_dist_inv_cur%notfound then
			  exit;
			end if;
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_invoice_currency_code :'||l_invoice_currency_code);

			open c_acc_min_dunn_amt (l_cust_account_id, l_invoice_currency_code);
			fetch c_acc_min_dunn_amt into l_min_dunning_amount, l_min_dunning_invoice_amount;
			/*
			if c_acc_dist_inv_cur%notfound then
				i := i +1;
				l_inc_inv_curr (i) := l_invoice_currency_code;
			end if;
			*/
			close c_acc_min_dunn_amt;
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_amount :'||l_min_dunning_amount);
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_invoice_amount :'||l_min_dunning_invoice_amount);

			if l_min_dunning_amount is null then
				l_min_dunning_amount := 0;
			end if;

			if l_min_dunning_invoice_amount is null then
				l_min_dunning_invoice_amount := 0;
			end if;

			l_amount		:= 0;
			l_tot_amt_due_rem	:= 0;

			      open c_dunningplan_lines (p_dunning_plan_id);
				 loop
					 fetch c_dunningplan_lines into l_dunningplan_lines;
					 exit when c_dunningplan_lines%notfound;

					 for i in l_dunningplan_lines.range_of_dunning_level_from..l_dunningplan_lines.range_of_dunning_level_to
					      loop
							WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - i: ' || i);
							l_stage	:= i-1;
							iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_stage :'||l_stage);

							if i = 1 then
								open c_cus_dunning_trx_null_dun_ct (l_party_id,
											    l_dunningplan_lines.min_days_between_dunning,
											    p_correspondence_date,
											    p_grace_days,
											    p_dun_disputed_items,
											    l_invoice_currency_code,
											    l_min_dunning_invoice_amount);
								 fetch c_cus_dunning_trx_null_dun_ct into l_amount;
								 close c_cus_dunning_trx_null_dun_ct;
								 iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_amount: ' || l_amount);
							else

								 open c_cus_dunning_trx_ct (l_party_id,
											   l_stage,
											   l_dunningplan_lines.min_days_between_dunning,
											   p_correspondence_date,
											   p_dun_disputed_items,
											   l_invoice_currency_code,
											   l_min_dunning_invoice_amount);
								 fetch c_cus_dunning_trx_ct into l_amount;
								 close c_cus_dunning_trx_ct;
								 iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_amount: ' || l_amount);
							end if;
							l_tot_amt_due_rem := l_tot_amt_due_rem + l_amount;
						end loop;
				end loop;
				close c_dunningplan_lines;



			--If any currency group satisfies the condition then we have to send the dunning letter,
			--so no need to check for other currencies.
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_tot_amt_due_rem: ' || l_tot_amt_due_rem);
			iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_min_dunning_amount: ' || l_min_dunning_amount);
			if l_tot_amt_due_rem >= l_min_dunning_amount then
				--l_dunning_letters := 'Y';
				i := i +1;
				l_inc_inv_curr (i) := l_invoice_currency_code;
			end if;
		      end loop;
		      close c_cus_dist_inv_cur;
		end if;
	end if;

    iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - l_inc_inv_curr.count: '|| l_inc_inv_curr.count);
    if l_inc_inv_curr.count = 0 then
	l_dunning_letters := 'N';
    else
	l_dunning_letters := 'Y';
    end if;

    p_inc_inv_curr := l_inc_inv_curr;
    p_dunning_letters := l_dunning_letters;

    iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - End');

EXCEPTION
 WHEN OTHERS THEN
    raise;
End StagedDunningMinAmountCheck;

Procedure MaxStageForanDelinquency (  p_delinquency_id   IN  number
                                    , p_stage_number     OUT NOCOPY number)
is
l_stage_number	number;
begin
	select max(iet.stage_number)
	into l_stage_number
	from iex_dunning_transactions iet,
	iex_dunnings dunn,
	iex_delinquencies_all del
	where iet.payment_schedule_id = del.payment_schedule_id
	and del.delinquency_id = p_delinquency_id
	and dunn.dunning_id = iet.dunning_id
	and ((dunn.dunning_mode = 'DRAFT' and dunn.confirmation_mode = 'CONFIRMED')
	      OR (dunn.dunning_mode = 'FINAL'))
	and dunn.delivery_status is null;

	p_stage_number	:= l_stage_number;

EXCEPTION
 WHEN OTHERS THEN
    raise;
end MaxStageForanDelinquency;

Procedure WriteLog      (  p_msg                     IN VARCHAR2)
IS
BEGIN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage (p_msg);
     END IF;

END WriteLog;

-- Begin- Andre 11/22/2005 - bug4740016 - Cache for SQL populated data.
FUNCTION get_cache_value (p_Identifier  IN VARCHAR2,
                             p_PopulateSql  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_return varchar2(80);
l_hash_value NUMBER;
BEGIN
  IF p_Identifier IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_Identifier||'@*?',
                                         1000,
                                         25000);

    IF pg_iexcache_rec.EXISTS(l_hash_value) THEN
        l_return := pg_iexcache_rec(l_hash_value);
    ELSE
       IF p_PopulateSql IS NOT NULL then
	-- simple select statement
	      EXECUTE IMMEDIATE p_PopulateSql
	      INTO l_return;
          pg_iexcache_rec(l_hash_value) := l_return;
       ELSE
          pg_iexcache_rec(l_hash_value) := Null;
       END IF;

    END IF;

  END IF;

  return(l_return);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;
-- End- Andre 11/22/2005 - bug4740016 - Cache for SQL populated data.

--Begin bug#4368394 schekuri 30-Nov-2005
--Added the following to provide a way to get the view by level of collections header
--in the database view itself
PROCEDURE SET_VIEW_BY_LEVEL(p_view_by in VARCHAR2) IS
BEGIN
    G_VIEW_BY_LEVEL:=p_view_by;
END SET_VIEW_BY_LEVEL;

FUNCTION GET_VIEW_BY_LEVEL RETURN VARCHAR2 IS
BEGIN
   IF G_VIEW_BY_LEVEL IS NULL THEN
	   RETURN 'PARTY';
   ELSE
	   RETURN G_VIEW_BY_LEVEL;
   END IF;
END GET_VIEW_BY_LEVEL;
--End bug#4368394 schekuri 30-Nov-2005


--Begin bug#4773082 ctlee 1-Dec-2005 performance issue
FUNCTION get_amount_due_remaining (p_customer_trx_id  IN number)
return number is
amount_due_remaining number;
 BEGIN
   select sum(amount_due_remaining) into amount_due_remaining from ar_payment_schedules_all
   where customer_trx_id = p_customer_trx_id;
   return amount_due_remaining;
EXCEPTION
 WHEN OTHERS THEN
    return amount_due_remaining;
END get_amount_due_remaining;
--End bug#4773082 ctlee 1-Dec-2005

--Begin bug#4864641 ctlee 6-Dec-2005 performance issue
FUNCTION get_amount_due_original (p_customer_trx_id  IN number)
return number is
amount_due_original number;
 BEGIN
   select sum(amount_due_original) into amount_due_original from ar_payment_schedules_all
   where customer_trx_id = p_customer_trx_id;
   return amount_due_original;
EXCEPTION
 WHEN OTHERS THEN
    return amount_due_original;
END get_amount_due_original;
--End bug#4864641 ctlee 6-Dec-2005 performance issue

--Begin bug#5373412 schekuri 10-Jul-2006
--Added the following procedure to consolidate the functionality of procedures
--get_billto_resources, get_assign_account_resources, get_assign_resources and get_access_resources
--into a single procedure.
-- This procedure will return the resource assigned to a customer, account, site, case
PROCEDURE get_assigned_collector(p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
                               p_level_id         IN  VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS

/* ------ SQLs assembled at run time -----------------------------------
CURSOR c_billto_collector is
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.site_use_id = p_site_use_id
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
  and nvl(ac.status,'A') = 'A'
  and nvl(hp.status,'A') = 'A'
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.site_use_id  = p_site_use_id
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.site_use_id  = p_site_use_id
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
      ) order by 3;

CURSOR c_account_collector IS
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.cust_account_id = p_account_id
  and hp.site_use_id is null
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
  and nvl(ac.status,'A') = 'A'
  and nvl(hp.status,'A') = 'A'
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.cust_account_id  = p_account_id
      and hp.site_use_id is NULL
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.cust_account_id  = p_account_id
      and hp.site_use_id is null
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
      ) order by 3;

cursor c_party_collector IS
SELECT ac.employee_id, ac.resource_id, 0
FROM  hz_customer_profiles hp, ar_collectors ac
WHERE hp.party_id = p_party_id
  and hp.cust_account_id = -1
  and hp.collector_id  = ac.collector_id
  and ac.resource_type = 'RS_RESOURCE'
  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
  and nvl(ac.status,'A') = 'A'
  and nvl(hp.status,'A') = 'A'
union all
( SELECT jtg.person_id, jtg.resource_id, count(work_item_id)
    FROM  hz_customer_profiles hp,  iex_strategy_work_items wi,
          ar_collectors ac, jtf_rs_group_members jtg
    WHERE hp.party_id  = P_PARTY_ID
      and hp.cust_account_id = -1
      and hp.collector_id  = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id  = jtg.group_id
      and jtg.resource_id = wi.resource_id
      and wi.status_code   = 'OPEN'
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
UNION ALL
    SELECT jtg.person_id, jtg.resource_id, 0
    FROM  hz_customer_profiles hp, ar_collectors ac,
      jtf_rs_group_members jtg
    WHERE hp.party_id  = p_party_id
      and hp.cust_account_id = -1
      and hp.collector_id   = ac.collector_id
      and ac.resource_type = 'RS_GROUP'
      and ac.resource_id = jtg.group_id
      and not exists (select null from iex_strategy_work_items wi
            where jtg.resource_id = wi.resource_id
      and wi.status_code = 'OPEN')
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      and nvl(jtg.delete_flag,'N') = 'N'
      group by jtg.resource_id, jtg.person_id
      ) order by 3;

  CURSOR c_case_collector IS
    SELECT ac.employee_id, ac.resource_id, count(cas_id)
    FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_cases_vl wi,ar_collectors ac
    WHERE hp.party_id = p_party_id
      and rs.resource_id = ac.resource_id
      and hp.collector_id = ac.collector_id
      and ac.resource_id = wi.owner_resource_id(+)
      and rs.user_id is not null
      and ac.employee_id is not null
      and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
      and nvl(ac.status,'A') = 'A'
      and nvl(hp.status,'A') = 'A'
      group by ac.resource_id, ac.employee_id ORDER BY 3;
*/

  l_api_version   CONSTANT NUMBER     := p_api_version;
  l_api_name CONSTANT VARCHAR2(100)   := 'get_assigned_collector';
  l_init_msg_list CONSTANT VARCHAR2(1):= p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
  l_count NUMBER := 0;

  l_select1 VARCHAR2(3000);
  l_select2 VARCHAR2(3000);
  l_select3 VARCHAR2(3000);
  l_select4 VARCHAR2(3000);
  --Begin Bug#5229763 schekuri 27-Jul-2006
  l_select5 VARCHAR2(3000);
  l_select6 VARCHAR2(3000);
  --End Bug#5229763 schekuri 27-Jul-2006

  l_where1 VARCHAR2(3000);
  l_where2 VARCHAR2(3000);
  l_where3 VARCHAR2(3000);
  l_where4 VARCHAR2(3000);
  --Begin Bug#5229763 schekuri 27-Jul-2006
  l_where5 VARCHAR2(3000);
  l_where6 VARCHAR2(3000);
  --End Bug#5229763 schekuri 27-Jul-2006

  l_group2 VARCHAR2(3000);
  l_group3 VARCHAR2(3000);
  l_group4 VARCHAR2(3000);
  --Begin Bug#5229763 schekuri 27-Jul-2006
  l_group5 VARCHAR2(3000);
  l_group6 VARCHAR2(3000);
  --End Bug#5229763 schekuri 27-Jul-2006

  l_order VARCHAR2(3000) := ' ORDER BY 3';
  l_union VARCHAR2(3000) := ' UNION ALL ';

  l_query VARCHAR2(32767);

  TYPE c_cur_type IS REF CURSOR;
  c_collector c_cur_type;

BEGIN

  iex_debug_pub.logmessage ('**** BEGIN get_assigned_collector ************');


  SAVEPOINT	get_assigned_collector;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Start Bug 7134688 gnramasa 17th June 08

  -- Initialize SQL statements - REMEMBER CHANGING 1 MEANS CHANGING ALL
  l_select1 :=              'SELECT ac.employee_id, ac.resource_id, 0 ';
  l_select1 := l_select1 || 'FROM  hz_customer_profiles hp, ar_collectors ac,jtf_rs_resource_extns rs ';
  l_where1  :=              'WHERE ';
  l_where1  := l_where1  || '      hp.collector_id  = ac.collector_id ';
  l_where1  := l_where1  || '  and ac.resource_type = ''RS_RESOURCE'' ';
  l_where1  := l_where1  || '  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where1  := l_where1  || '  and nvl(ac.status,''A'') = ''A'' ';
  l_where1  := l_where1  || '  and nvl(hp.status,''A'') = ''A'' ';
  l_where1  := l_where1  || '  and ac.resource_id = rs.resource_id ';
  l_where1  := l_where1  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';

  l_select2 :=              'SELECT jtg.person_id, jtg.resource_id, count(work_item_id) ';
  l_select2 := l_select2 || 'FROM hz_customer_profiles hp,  iex_strategy_work_items wi, ';
  l_select2 := l_select2 || '     ar_collectors ac, jtf_rs_group_members jtg, jtf_rs_resource_extns rs ';
  l_select2 := l_select2 || '     , jtf_rs_role_relations jtr,JTF_RS_ROLES_b jtrr ';
  l_where2  :=              'WHERE ';
  l_where2  := l_where2  || '      hp.collector_id  = ac.collector_id ';
  l_where2  := l_where2  || '  and ac.resource_type = ''RS_GROUP'' ';
  l_where2  := l_where2  || '  and ac.resource_id  = jtg.group_id ';
  l_where2  := l_where2  || '  and jtg.resource_id = wi.resource_id ';
  l_where2  := l_where2  || '  and jtg.group_member_id = jtr.role_resource_id ';
  l_where2  := l_where2  || '  and jtr.role_id=jtrr.role_id ';
  l_where2  := l_where2  || '  and jtrr.role_type_code=''COLLECTIONS'' ';
  l_where2  := l_where2  || '  and wi.status_code   = ''OPEN'' ';
  l_where2  := l_where2  || '  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where2  := l_where2  || '  and nvl(ac.status,''A'') = ''A'' ';
  l_where2  := l_where2  || '  and nvl(hp.status,''A'') = ''A'' ';
  l_where2  := l_where2  || '  and nvl(jtg.delete_flag,''N'') = ''N'' ';
  l_where2  := l_where2  || '  AND nvl(jtr.delete_flag,''N'') = ''N'' ';
  l_where2  := l_where2  || '  and jtg.resource_id = rs.resource_id ';
  l_where2  := l_where2  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_where2  := l_where2  || '  and trunc(nvl(jtr.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_group2  :=              'group by jtg.resource_id, jtg.person_id ';

  l_select3 :=              'SELECT jtg.person_id, jtg.resource_id, 0 ';
  l_select3 := l_select3 || 'FROM hz_customer_profiles hp, ar_collectors ac,  ';
  l_select3 := l_select3 || '     jtf_rs_group_members jtg, jtf_rs_resource_extns rs ';
  l_select3 := l_select3 || '     , jtf_rs_role_relations jtr,JTF_RS_ROLES_b jtrr ';
  l_where3  :=              ' WHERE ';
  l_where3  := l_where3  || '      hp.collector_id   = ac.collector_id ';
  l_where3  := l_where3  || '  and ac.resource_type = ''RS_GROUP'' ';
  l_where3  := l_where3  || '  and ac.resource_id = jtg.group_id    ';
  l_where3  := l_where3  || '  and jtg.group_member_id = jtr.role_resource_id ';
  l_where3  := l_where3  || '  and jtr.role_id=jtrr.role_id ';
  l_where3  := l_where3  || '  and jtrr.role_type_code=''COLLECTIONS'' ';
  l_where3  := l_where3  || '  and not exists (select null from iex_strategy_work_items wi ';
  l_where3  := l_where3  || '                  where jtg.resource_id = wi.resource_id ';
  l_where3  := l_where3  || '                    and wi.status_code = ''OPEN'') ';
  l_where3  := l_where3  || ' and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where3  := l_where3  || ' and nvl(ac.status,''A'') = ''A'' ';
  l_where3  := l_where3  || ' and nvl(hp.status,''A'') = ''A'' ';
  l_where3  := l_where3  || ' and nvl(jtg.delete_flag,''N'') = ''N'' ';
  l_where3  := l_where3  || ' and nvl(jtr.delete_flag,''N'') = ''N'' ';
  l_where3  := l_where3  || '  and jtg.resource_id = rs.resource_id ';
  l_where3  := l_where3  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_where3  := l_where3  || '  and trunc(nvl(jtr.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_group3  :=              ' group by jtg.resource_id, jtg.person_id ';

  l_select4 :=              'SELECT ac.employee_id, ac.resource_id, count(cas_id) ';
  --Begin Bug#6962575 29-Jul-2008 barathsr
 -- l_select4 := l_select4 || '  FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_cases_vl wi,ar_collectors ac ';
 l_select4 := l_select4 || '  FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs, iex_cases_all_b wi,ar_collectors ac ';
  --End Bug#6962575 29-Jul-2008 barathsr
  l_where4  :=              '  WHERE hp.party_id = :1 ';
  l_where4  := l_where4  || '    and rs.resource_id = ac.resource_id ';
  l_where4  := l_where4  || '    and hp.collector_id = ac.collector_id ';
  l_where4  := l_where4  || '    and ac.resource_id = wi.owner_resource_id(+) ';
  l_where4  := l_where4  || '    and rs.user_id is not null ';
  l_where4  := l_where4  || '    and ac.employee_id is not null ';
  l_where4  := l_where4  || '    and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where2  := l_where2  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_where4  := l_where4  || '    and nvl(ac.status,''A'') = ''A'' ';
  l_where4  := l_where4  || '    and nvl(hp.status,''A'') = ''A'' ';
  l_group4  := l_group4  || '    group by ac.resource_id, ac.employee_id ORDER BY 3 ';

  --Begin Bug#5229763 schekuri 27-Jul-2006
  --Added following sql's for getting resource for task creation in dunning callback concurrent program
    l_select5 :=              ' SELECT jtg.person_id, jtg.resource_id, count(t.task_id) ';
  l_select5 := l_select5 || ' FROM hz_customer_profiles hp,  jtf_tasks_vl t, jtf_task_statuses_vl s, ';
  l_select5 := l_select5 || '     ar_collectors ac, jtf_rs_group_members jtg, jtf_rs_resource_extns rs ';
  l_select5 := l_select5 || '     , jtf_rs_role_relations jtr,JTF_RS_ROLES_b jtrr ';
  l_where5  :=              ' WHERE ';
  l_where5  := l_where5  || '      hp.collector_id  = ac.collector_id ';
  l_where5  := l_where5  || '  and ac.resource_type = ''RS_GROUP'' ';
  l_where5  := l_where5  || '  and ac.resource_id  = jtg.group_id ';
  l_where5  := l_where5  || '  and jtg.resource_id = t.owner_id ';
  l_where5  := l_where5  || '  and jtg.group_member_id = jtr.role_resource_id ';
  l_where5  := l_where5  || '  and jtr.role_id=jtrr.role_id ';
  l_where5  := l_where5  || '  and jtrr.role_type_code=''COLLECTIONS'' ';
  l_where5  := l_where5  || '  and t.task_name = ''Dunning Callback'' ';
  l_where5  := l_where5  || '  and t.task_status_id = s.task_status_id ';
  l_where5  := l_where5  || '  and upper(s.name) = ''OPEN'' ';
  l_where5  := l_where5  || '  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where5  := l_where5  || '  and nvl(ac.status,''A'') = ''A'' ';
  l_where5  := l_where5  || '  and nvl(hp.status,''A'') = ''A'' ';
  l_where5  := l_where5  || '  and nvl(jtg.delete_flag,''N'') = ''N'' ';
  l_where5  := l_where5  || '  and nvl(jtr.delete_flag,''N'') = ''N'' ';
  l_where5  := l_where5  || '  and jtg.resource_id = rs.resource_id ';
  l_where5  := l_where5  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_where5  := l_where5  || '  and trunc(nvl(jtr.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_group5  :=              'group by jtg.resource_id, jtg.person_id ';

  l_select6 :=              'SELECT jtg.person_id, jtg.resource_id, 0 ';
  l_select6 := l_select6 || ' FROM hz_customer_profiles hp, ar_collectors ac,  ';
  l_select6 := l_select6 || '     jtf_rs_group_members jtg, jtf_rs_resource_extns rs ';
  l_select6 := l_select6 || '     , jtf_rs_role_relations jtr,JTF_RS_ROLES_b jtrr ';
  l_where6  :=              ' WHERE ';
  l_where6  := l_where6  || '      hp.collector_id   = ac.collector_id ';
  l_where6  := l_where6  || '  and ac.resource_type = ''RS_GROUP'' ';
  l_where6  := l_where6  || '  and ac.resource_id = jtg.group_id    ';
  l_where6  := l_where6  || '  and jtg.group_member_id = jtr.role_resource_id ';
  l_where6  := l_where6  || '  and jtr.role_id=jtrr.role_id ';
  l_where6  := l_where6  || '  and jtrr.role_type_code=''COLLECTIONS'' ';
  l_where6  := l_where6  || '  and not exists (select 1 from jtf_tasks_vl t, jtf_task_statuses_vl s ';
  l_where6  := l_where6  || '  where jtg.resource_id = t.owner_id ';
  l_where6  := l_where6  || '  and t.task_name = ''Dunning Callback'' ';
  l_where6  := l_where6  || '  and t.task_status_id = s.task_status_id ';
  l_where6  := l_where6  || '  and upper(s.name) = ''OPEN'') ';
  l_where6  := l_where6  || ' and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where6  := l_where6  || ' and nvl(ac.status,''A'') = ''A'' ';
  l_where6  := l_where6  || ' and nvl(hp.status,''A'') = ''A'' ';
  l_where6  := l_where6  || ' and nvl(jtg.delete_flag,''N'') = ''N'' ';
  l_where6  := l_where6  || ' and nvl(jtr.delete_flag,''N'') = ''N'' ';
  l_where6  := l_where6  || ' and jtg.resource_id = rs.resource_id ';
  l_where6  := l_where6  || ' and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_where6  := l_where6  || ' and trunc(nvl(jtr.end_date_active,sysdate)) >= trunc(sysdate) ';
  l_group6  :=              ' group by jtg.resource_id, jtg.person_id ';
  --End Bug#5229763 schekuri 27-Jul-2006
  --End Bug 7134688 gnramasa 17th June 08

  if p_level = 'PARTY' then
     l_query := l_select1 || l_where1 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' ;
     l_query := l_query || l_union || '( ' || l_select2 || l_where2 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' || l_group2;
     l_query := l_query || l_union || l_select3 || l_where3 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' || l_group3 || ' )' || l_order;
  end if;
  if p_level = 'ACCOUNT' then
     l_query := l_select1 || l_where1 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' ;
     l_query := l_query || l_union || '( ' || l_select2 || l_where2 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' || l_group2;
     l_query := l_query || l_union || l_select3 || l_where3 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' || l_group3 || ' )' || l_order;
  end if;
  if p_level = 'BILLTO' then
     l_query := l_select1 || l_where1 || ' and hp.site_use_id = :1 ' ;
     l_query := l_query || l_union || '( ' || l_select2 || l_where2 || ' and hp.site_use_id = :1 ' || l_group2;
     l_query := l_query || l_union || l_select3 || l_where3 || ' and hp.site_use_id = :1 ' || l_group3 || ' )' || l_order;
  end if;
  if p_level = 'CASE' then
     l_query := l_select4 || l_where4 || l_group4 ;
  end if;
  --Begin Bug#5229763 schekuri 27-Jul-2006
  --Added following for getting resource for task creation in dunning callback concurrent program
  if p_level = 'DUNNING_PARTY' then
     l_query := l_select1 || l_where1 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' ;
     l_query := l_query || l_union || '( ' || l_select5 || l_where5 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' || l_group5;
     l_query := l_query || l_union || l_select6 || l_where6 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' || l_group6 || ' )' || l_order;
  end if;
  if p_level = 'DUNNING_ACCOUNT' then
     l_query := l_select1 || l_where1 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' ;
     l_query := l_query || l_union || '( ' || l_select5 || l_where5 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' || l_group5;
     l_query := l_query || l_union || l_select6 || l_where6 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' || l_group6 || ' )' || l_order;
  end if;
  if p_level = 'DUNNING_BILLTO' then
     l_query := l_select1 || l_where1 || ' and hp.site_use_id = :1 ' ;
     l_query := l_query || l_union || '( ' || l_select5 || l_where5 || ' and hp.site_use_id = :1 ' || l_group5;
     l_query := l_query || l_union || l_select6 || l_where6 || ' and hp.site_use_id = :1 ' || l_group6 || ' )' || l_order;
  end if;
  if p_level = 'DUNNING_PARTY_ACCOUNT' then
     l_query := l_select1 || l_where1 || ' and hp.party_id = :1 and hp.cust_account_id <> -1 and hp.site_use_id is null ' ;
     l_query := l_query || l_union || '( ' || l_select5 || l_where5 || ' and hp.party_id = :1 and hp.cust_account_id <> -1 and hp.site_use_id is null ' || l_group5;
     l_query := l_query || l_union || l_select6 || l_where6 || ' and hp.party_id = :1 and hp.cust_account_id <> -1 and hp.site_use_id is null ' || l_group6 || ' )' || l_order;
  end if;
  --End Bug#5229763 schekuri 27-Jul-2006

  -- End SQL statements

  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Parameters: ');
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_level: ' || p_level);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_level_id: ' || p_level_id);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data query is: ' || l_query);

  --if p_level = 'PARTY' or p_level = 'ACCOUNT' or p_level = 'BILLTO' then
  if p_level <> 'CASE' then              --Modified for Bug#5229763 schekuri 27-Jul-2006
     OPEN c_collector FOR l_query USING p_level_id, p_level_id, p_level_id;
  else
     OPEN c_collector FOR l_query USING p_level_id;
  end if;

  LOOP
     idx := idx + 1;
          -- Begin fix bug #5360791-JYPARK-06/28/2006-Change fetch variable order
 	  -- FETCH c_collector INTO x_resource_tab(idx).resource_id,
          --                  x_resource_tab(idx).person_id,
          --                   l_count;
 	  FETCH c_collector INTO x_resource_tab(idx).person_id,
                            x_resource_tab(idx).resource_id,
                            l_count;
          -- End fix bug #5360791-JYPARK-06/28/2006-Change fetch variable order
     if c_collector%notfound then
	       exit;
     end if;

     iex_debug_pub.logmessage (G_PKG_NAME || '.' || l_api_name || 'idx= ' || idx);
     iex_debug_pub.logmessage (G_PKG_NAME || '.' || l_api_name || 'collector_resource_id = ' || x_resource_tab(idx).person_id);
  End LOOP;

  CLOSE c_collector;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  iex_debug_pub.logmessage ('**** END get_assigned_collector ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_assigned_collector;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_assigned_collector;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
      ROLLBACK TO get_assigned_collector;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_assigned_collector;
--End bug#5373412 schekuri 10-Jul-2006

--Start adding for bug 9162623 gnramasa 2nd Dec 09
-- This procedure will return the resource assigned to a customer, account, site
PROCEDURE get_dunning_resource(p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
                               p_level_id         IN  VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_resource_tab     OUT NOCOPY resource_tab_type) IS

  l_api_version   CONSTANT NUMBER     := p_api_version;
  l_api_name CONSTANT VARCHAR2(100)   := 'get_dunning_resource';
  l_init_msg_list CONSTANT VARCHAR2(1):= p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  idx NUMBER := 0;
  l_count NUMBER := 0;

  l_select1 VARCHAR2(3000);
  l_select2 VARCHAR2(3000);

  l_where1 VARCHAR2(3000);
  l_where2 VARCHAR2(3000);

  l_union VARCHAR2(3000) := ' UNION ALL ';

  l_query VARCHAR2(32767);

  TYPE c_cur_type IS REF CURSOR;
  c_collector c_cur_type;

BEGIN

  iex_debug_pub.logmessage ('**** BEGIN get_dunning_resource ************');


  SAVEPOINT	get_dunning_resource;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize SQL statements - REMEMBER CHANGING 1 MEANS CHANGING ALL
  l_select1 :=              'SELECT ac.employee_id, ac.resource_id ';
  l_select1 := l_select1 || 'FROM  hz_customer_profiles hp, ar_collectors ac,jtf_rs_resource_extns rs ';
  l_where1  :=              'WHERE ';
  l_where1  := l_where1  || '      hp.collector_id  = ac.collector_id ';
  l_where1  := l_where1  || '  and ac.resource_type = ''RS_RESOURCE'' ';
  l_where1  := l_where1  || '  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where1  := l_where1  || '  and nvl(ac.status,''A'') = ''A'' ';
  l_where1  := l_where1  || '  and nvl(hp.status,''A'') = ''A'' ';
  l_where1  := l_where1  || '  and ac.resource_id = rs.resource_id ';
  l_where1  := l_where1  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';

  l_select2 :=              'SELECT ac.employee_id, rs.resource_id ';
  l_select2 := l_select2 || 'FROM  hz_customer_profiles hp, ar_collectors ac,jtf_rs_resource_extns rs ';
  l_where2  :=              'WHERE ';
  l_where2  := l_where2  || '      hp.collector_id  = ac.collector_id ';
  l_where2  := l_where2  || '  and ac.resource_type = ''RS_GROUP'' ';
  l_where2  := l_where2  || '  and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate) ';
  l_where2  := l_where2  || '  and nvl(ac.status,''A'') = ''A'' ';
  l_where2  := l_where2  || '  and nvl(hp.status,''A'') = ''A'' ';
  l_where2  := l_where2  || '  and ac.employee_id = rs.source_id ';
  l_where2  := l_where2  || '  and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate) ';

  if p_level = 'DUNNING_PARTY' then
     l_query := l_select1 || l_where1 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ' ;
     l_query := l_query || l_union || l_select2 || l_where2 || ' and hp.party_id = :1 and hp.cust_account_id = -1 ';
  end if;
  if p_level = 'DUNNING_ACCOUNT' then
     l_query := l_select1 || l_where1 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' ;
     l_query := l_query || l_union || l_select2 || l_where2 || ' and hp.cust_account_id = :1 and hp.site_use_id is null ' ;
  end if;
  if p_level = 'DUNNING_BILLTO' then
     l_query := l_select1 || l_where1 || ' and hp.site_use_id = :1 ' ;
     l_query := l_query || l_union || l_select2 || l_where2 || ' and hp.site_use_id = :1 ' ;
  end if;
  if p_level = 'DUNNING_PARTY_ACCOUNT' then
     l_query := l_select1 || l_where1 || ' and hp.party_id = :1 and hp.cust_account_id <> -1 and hp.site_use_id is null ' ;
     l_query := l_query || l_union || l_select2 || l_where2 || ' and hp.party_id = :1 and hp.cust_account_id <> -1 and hp.site_use_id is null ' ;
  end if;

  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Parameters: ');
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_level: ' || p_level);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_level_id: ' || p_level_id);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Data query is: ' || l_query);

  OPEN c_collector FOR l_query USING p_level_id, p_level_id;

  LOOP
     idx := idx + 1;
 	  FETCH c_collector INTO x_resource_tab(idx).person_id,
                            x_resource_tab(idx).resource_id;
     if c_collector%notfound then
	       exit;
     end if;

     iex_debug_pub.logmessage (G_PKG_NAME || '.' || l_api_name || 'idx= ' || idx);
     iex_debug_pub.logmessage (G_PKG_NAME || '.' || l_api_name || 'collector_resource_id = ' || x_resource_tab(idx).person_id);
  End LOOP;

  CLOSE c_collector;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  iex_debug_pub.logmessage ('**** END get_dunning_resource ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_dunning_resource;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_dunning_resource;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
      ROLLBACK TO get_dunning_resource;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_dunning_resource;
--End adding for bug 9162623 gnramasa 2nd Dec 09

--Start adding for staged dunning gnramasa 7th Dec 09
-- This procedure will return the grace days of a customer, account, site
PROCEDURE get_grace_days (p_api_version    IN  NUMBER := 1.0,
                               p_init_msg_list    IN  VARCHAR2,
                               p_commit           IN  VARCHAR2,
                               p_validation_level IN  NUMBER,
                               p_level            IN  VARCHAR2,
			       p_party_id         IN  NUMBER,
			       p_account_id       IN  NUMBER,
			       p_site_use_id      IN  NUMBER,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_grace_days       OUT NOCOPY NUMBER) IS

  l_api_version   CONSTANT NUMBER     := p_api_version;
  l_api_name CONSTANT VARCHAR2(100)   := 'get_grace_days';
  l_init_msg_list CONSTANT VARCHAR2(1):= p_init_msg_list;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);

  cursor c_gracedays_party_level (p_party_id number) is
  select nvl(payment_grace_days ,0)
  from hz_customer_profiles
  where party_id = p_party_id
  and cust_account_id = -1;

  cursor c_gracedays_acc_level (p_party_id number, p_cust_acct_id number) is
  select nvl(payment_grace_days ,0)
  from hz_customer_profiles
  where party_id = p_party_id
  and cust_account_id = p_cust_acct_id
  and site_use_id is null;

  cursor c_gracedays_billto_level (p_party_id number, p_cust_acct_id number, p_site_use_id number) is
  select nvl(payment_grace_days ,0)
  from hz_customer_profiles
  where party_id = p_party_id
  and cust_account_id = p_cust_acct_id
  and site_use_id = p_site_use_id;

  l_grace_days	number := 0;

BEGIN

  iex_debug_pub.logmessage ('**** BEGIN get_grace_days ************');


  SAVEPOINT	get_grace_days;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':Parameters: ');
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_level: ' || p_level);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_party_id: ' || p_party_id);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_account_id: ' || p_account_id);
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':p_site_use_id: ' || p_site_use_id);

  if p_level = 'PARTY' then
     open c_gracedays_party_level (p_party_id);
     fetch c_gracedays_party_level into l_grace_days;
     close c_gracedays_party_level;
  end if;
  if p_level = 'ACCOUNT' then
     open c_gracedays_acc_level (p_party_id, p_account_id);
     fetch c_gracedays_acc_level into l_grace_days;
     close c_gracedays_acc_level;
  end if;
  if p_level = 'BILL_TO' then
     open c_gracedays_billto_level (p_party_id, p_account_id, p_site_use_id);
     fetch c_gracedays_billto_level into l_grace_days;
     close c_gracedays_billto_level;
  end if;
  iex_debug_pub.LogMessage(G_PKG_NAME || '.' || l_api_name || ':l_grace_days: ' || l_grace_days);

  x_grace_days	:= l_grace_days;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
   COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  iex_debug_pub.logmessage ('**** END get_grace_days ************');

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_grace_days;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_grace_days;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
      ROLLBACK TO get_grace_days;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END get_grace_days;
--End adding for staged dunning gnramasa 7th Dec 09

--Begin bug 6723556 gnramasa 11th Jan 08
--If all the tranactions that belong to a contract has a status not equal to CURRENT or CLOSE
--then return contract status as DELINQUENT else return as CURRENT

FUNCTION CheckContractStatus
(
  p_contract_number    IN  VARCHAR2
)
return varchar2 is
l_contract_status  VARCHAR2(10) := 'CURRENT';
l_count            NUMBER := 0;
BEGIN
iex_debug_pub.logmessage ('Start CheckContractStatus');
iex_debug_pub.logmessage ('p_contract_number :' || p_contract_number);

IF p_contract_number IS NOT NULL then
	select count(1) into l_count
	from iex_delinquencies_all del,ra_customer_trx_lines_all trl
        where del.TRANSACTION_ID = trl.CUSTOMER_TRX_ID
          and del.status not in ('CURRENT', 'CLOSE')
          and trl.INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS'
          and trl.INTERFACE_LINE_ATTRIBUTE6 = p_contract_number;

	if l_count >1 then
		l_contract_status := 'DELINQUENT';
	else
		l_contract_status := 'CURRENT';
	end if;
END IF;
iex_debug_pub.logmessage ('CheckContractStatus : l_contract_status :' || l_contract_status);
iex_debug_pub.logmessage ('End CheckContractStatus');
return l_contract_status;
EXCEPTION
 WHEN OTHERS THEN
    iex_debug_pub.logmessage ('CheckContractStatus: In other exception');
    iex_debug_pub.logmessage ('CheckContractStatus : l_contract_status :' || l_contract_status);
    return l_contract_status;
END;
--End bug 6723556 gnramasa 11th Jan 08

--Begin bug 6627832 gnramasa 21st Jan 08
FUNCTION ValidateXMLRequestId
(
  p_xml_request_id    IN  number
) return boolean is
l_req_count number;
begin
      select count(1)
      into l_req_count
      from iex_xml_request_histories
      where xml_request_id=p_xml_request_id
      and length(document)>0;
      if l_req_count>0 then
      return true;
      else
      return false;
      end if;
exception
when others then
return false;
end;
--End bug 6627832 gnramasa 21st Jan 08

--Begin bug 6717279 by gnramasa 25th Aug 08
-- this function will copy the value to pl/sql table.
Procedure copy_cust_acct_value
 (
   p_fe_cust_acct_rec IN DBMS_SQL.NUMBER_TABLE
 ) is
	l_count   number;
begin
	iex_debug_pub.logmessage ('Begin copy_cust_acct_value');
	l_count := p_fe_cust_acct_rec.count;
	iex_debug_pub.logmessage ('copy_cust_acct_value, l_count: ' || l_count);
	p_be_cust_acct_rec.delete;
	for i in 1..l_count loop
		p_be_cust_acct_rec(i) := p_fe_cust_acct_rec(i);
		iex_debug_pub.logmessage ('p_be_cust_acct_rec('||i||') : ' || p_be_cust_acct_rec(i));
	end loop;
	iex_debug_pub.logmessage ('End copy_cust_acct_value');
End copy_cust_acct_value;

--this function accepts cust_account_id. If this value exists in the pl/sql table
--then it will return 'Y', else 'N'
FUNCTION cust_acct_id_check
(
  p_cust_acct_id    IN  number
)
	return varchar is
	l_count   number;
begin
	iex_debug_pub.logmessage ('Begin cust_acct_id_check');
	iex_debug_pub.logmessage ('cust_acct_id_check, p_cust_acct_id: ' || p_cust_acct_id);
	l_count := p_be_cust_acct_rec.count;
	iex_debug_pub.logmessage ('cust_acct_id_check, l_count: ' || l_count);
	for i in 1..l_count loop
		if p_be_cust_acct_rec(i) = p_cust_acct_id then
			iex_debug_pub.logmessage ('cust_acct_id_check, value exists in pl/sql table, so returning Y');
			return 'Y';  -- value exists in pl/sql table, so return 'Y'
		end if;
	end loop;
	iex_debug_pub.logmessage ('End cust_acct_id_check');
	iex_debug_pub.logmessage ('cust_acct_id_check, value doesn''t exists in pl/sql table, so returning N');
	return 'N'; -- value doesn't exists in pl/sql table, so return 'N'
End cust_acct_id_check;
--End bug 6717279 by gnramasa 25th Aug 08

--Begin bug#6717849 by schekuri 27-Jul-2009
--Created for multi level strategy enhancement

FUNCTION VALIDATE_RUNNING_LEVEL
(
      p_running_level IN  varchar2
)
return varchar2 is
l_return_value VARCHAR2(1);
begin
	select nvl(decode(P_RUNNING_LEVEL,'CUSTOMER',USING_CUSTOMER_LEVEL,
	                                'ACCOUNT',USING_ACCOUNT_LEVEL,
					'BILL_TO',USING_BILLTO_LEVEL,
					'DELINQUENCY',USING_DELINQUENCY_LEVEL,'N'),'N')
	INTO l_return_value
	from IEX_QUESTIONNAIRE_ITEMS;

	return l_return_value;

end;

FUNCTION GET_PARTY_RUNNING_LEVEL
(
      p_party_id IN  NUMBER,
      p_org_id IN NUMBER DEFAULT NULL
)
return varchar2 is
	cursor c_party_bus_level(p_party_id number) is
	select value_varchar2 from hz_party_preferences
	where module = 'COLLECTIONS'
	and category='COLLECTIONS LEVEL'
	and preference_code='PARTY_ID'
	and party_id=p_party_id;

        cursor c_ou_bus_level(p_org_id number) is
	select preference_value
	from iex_app_preferences_b
	where preference_name='COLLECTIONS STRATEGY LEVEL'
	and org_id is not null
	and org_id=p_org_id
	and enabled_flag='Y';

        cursor c_system_bus_level is
	select preference_value
	from iex_app_preferences_b
	where preference_name='COLLECTIONS STRATEGY LEVEL'
	and org_id is null
	and enabled_flag='Y';

	l_running_level varchar2(20);
	l_using_party_business_level varchar2(1);
	l_using_ou_business_level varchar2(1);


	cursor c_questionnaire is
	select DEFINE_PARTY_RUNNING_LEVEL,
	       DEFINE_OU_RUNNING_LEVEL
	from IEX_QUESTIONNAIRE_ITEMS;

	cursor c_unique_ous(p_partyid number) is
	select distinct org_id
	from iex_delinquencies_all
	where status in ('DELINQUENT','PREDELINQUENT')
	and party_cust_id=p_partyid;

	l_org_id number;



begin

        open c_questionnaire;
	fetch c_questionnaire into l_using_party_business_level,l_using_ou_business_level;
	close c_questionnaire;

	if l_using_party_business_level='Y' then

	if p_party_id is not null then
		open c_party_bus_level(p_party_id);
		fetch c_party_bus_level into l_running_level;
		close c_party_bus_level;
		if l_running_level is not null then
			return l_running_level;
		end if;
	end if;

	end if;

	if l_using_ou_business_level='Y' then

	if p_org_id is not null then
		open c_ou_bus_level(p_org_id);
		fetch c_ou_bus_level into l_running_level;
		close c_ou_bus_level;
		if l_running_level is not null then
			return l_running_level;
		end if;
	else
	if p_party_id is not null then

		open c_unique_ous(p_party_id);
		loop
			fetch c_unique_ous into l_org_id;
			if c_unique_ous%rowcount>1 then
				l_org_id:=null;
				exit;
			end if;
			exit when c_unique_ous%notfound;
		end loop;
		close c_unique_ous;

		if l_org_id is not null then
			open c_ou_bus_level(p_org_id);
			fetch c_ou_bus_level into l_running_level;
			close c_ou_bus_level;
			if l_running_level is not null then
				return l_running_level;
			end if;
		end if;

	end if;

	end if;

	end if;

	open c_system_bus_level;
	fetch c_system_bus_level into l_running_level;
	close c_system_bus_level;

	return l_running_level;


end;
--End bug#6717849 by schekuri 27-Jul-2009
BEGIN
  G_APPL_ID := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID      := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID    := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID       := FND_GLOBAL.User_Id;
  G_REQUEST_ID    := FND_GLOBAL.Conc_Request_Id;

  PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END IEX_UTILITIES;

/
