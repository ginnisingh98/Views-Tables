--------------------------------------------------------
--  DDL for Package Body AS_SALES_ORG_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_ORG_MANAGER_PVT" as
/* $Header: asxvsomb.pls 120.1 2005/06/23 01:05:40 appldev ship $ */

--
-- NAME
--   AS_SALES_ORG_MANAGER_PVT
--
-- HISTORY
--   6/19/98        ALHUNG        CREATED
--
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_SALES_ORG_MANAGER_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvsomb.pls';


-- Following are private procedures and functions used by Get_Sales_Groups

Function get_sales_group_gen_select return Varchar2 IS

    l_select_cl Varchar2(500);

  Begin
    l_select_cl := 'Select ' ||
                   'Sales_Group_id, Name, Start_Date_Active, End_Date_Active, ' ||
                   'Description, Parent_Sales_Group_ID, Manager_Person_Id, ' ||
                   'Manager_Salesforce_Id, Accounting_Code ' ||
                   'From AS_SALES_GROUPS_V ' ||
                   'Where 1=1 ';
    return l_select_cl;


  End get_sales_group_gen_select;

Function get_sales_group_gen_where(p_sales_group_rec IN AS_SALES_GROUP_PUB.Sales_Group_Rec_Type)
    return Varchar2  IS

    l_where_cl Varchar2(1000);

  Begin

    If (p_sales_group_rec.sales_group_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And sales_group_id = :p_sales_group_id ';
    End if;

    If (p_sales_group_rec.name <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And name like :p_name ';
    End if;

    If (p_sales_group_rec.parent_sales_group_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And parent_sales_group_id = :p_parent_sales_group_id ';
    End if;

    If (p_sales_group_rec.manager_person_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And manager_person_id = :p_manager_person_id ';
    End if;

    If (p_sales_group_rec.manager_salesforce_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And manager_salesforce_id = :p_manager_salesforce_id ';
    End if;

    return l_where_cl;

  End get_sales_group_gen_where;

Procedure get_sales_group_define_columns(p_cur_get_salesgroup IN Number) IS

    l_sales_group_rec AS_SALES_GROUP_PUB.Sales_Group_Rec_Type;

  Begin

    dbms_sql.define_column(p_cur_get_salesgroup, 1, l_sales_group_rec.sales_group_id);
    dbms_sql.define_column(p_cur_get_salesgroup, 2, l_sales_group_rec.name, 60);
    dbms_sql.define_column(p_cur_get_salesgroup, 3, l_sales_group_rec.start_date_active);
    dbms_sql.define_column(p_cur_get_salesgroup, 4, l_sales_group_rec.end_date_active);
    dbms_sql.define_column(p_cur_get_salesgroup, 5, l_sales_group_rec.description, 240);
    dbms_sql.define_column(p_cur_get_salesgroup, 6, l_sales_group_rec.parent_sales_group_id);
    dbms_sql.define_column(p_cur_get_salesgroup, 7, l_sales_group_rec.manager_person_id);
    dbms_sql.define_column(p_cur_get_salesgroup, 8, l_sales_group_rec.manager_salesforce_id);
    dbms_sql.define_column(p_cur_get_salesgroup, 9, l_sales_group_rec.accounting_code, 80);

  End get_sales_group_define_columns;

Procedure get_sales_group_bind_variables(p_cur_get_salesgroup IN Number,
                             p_sales_group_rec IN AS_SALES_GROUP_PUB.Sales_Group_Rec_Type) IS

  Begin
    If (p_sales_group_rec.sales_group_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesgroup, 'p_sales_group_id',
            p_sales_group_rec.sales_group_id);
    End if;

    If (p_sales_group_rec.name <> FND_API.G_MISS_CHAR) Then
        dbms_sql.bind_variable(p_cur_get_salesgroup, 'p_name',
            p_sales_group_rec.name);
    End if;

    If (p_sales_group_rec.parent_sales_group_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesgroup, 'p_parent_sales_group_id',
            p_sales_group_rec.parent_sales_group_id);
    End if;

    If (p_sales_group_rec.manager_person_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesgroup, 'p_manager_person_id',
            p_sales_group_rec.manager_person_id);
    End if;

    If (p_sales_group_rec.manager_salesforce_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesgroup, 'p_manager_salesforce_id',
            p_sales_group_rec.manager_salesforce_id);
    End if;
  End get_sales_group_bind_variables;

Procedure get_sales_group_column_values(p_cur_get_salesgroup IN Number,
                            x_sales_group_rec OUT NOCOPY AS_SALES_GROUP_PUB.Sales_Group_Rec_Type) IS

  Begin

    dbms_sql.column_value(p_cur_get_salesgroup, 1, x_sales_group_rec.sales_group_id);
    dbms_sql.column_value(p_cur_get_salesgroup, 2, x_sales_group_rec.name);
    dbms_sql.column_value(p_cur_get_salesgroup, 3, x_sales_group_rec.start_date_active);
    dbms_sql.column_value(p_cur_get_salesgroup, 4, x_sales_group_rec.end_date_active);
    dbms_sql.column_value(p_cur_get_salesgroup, 5, x_sales_group_rec.description);
    dbms_sql.column_value(p_cur_get_salesgroup, 6, x_sales_group_rec.parent_sales_group_id);
    dbms_sql.column_value(p_cur_get_salesgroup, 7, x_sales_group_rec.manager_person_id);
    dbms_sql.column_value(p_cur_get_salesgroup, 8, x_sales_group_rec.manager_salesforce_id);
    dbms_sql.column_value(p_cur_get_salesgroup, 9, x_sales_group_rec.accounting_code);

  End get_sales_group_column_values;

  -- Following are private procedures and functions used by get_salesmem

  Function get_salesmem_gen_select return Varchar2 IS

    l_select_cl Varchar2(500);

  Begin
    l_select_cl := 'Select ' ||
                   'force.salesforce_id, force.type, force.start_date_active, force.end_date_active, ' ||
                   'force.employee_person_id, null, force.Partner_address_id, ' ||
-- remove partner_contact_id
--                   'force.partner_customer_id, force.partner_contact_id, people.last_name, ' ||
                   'force.partner_customer_id, people.last_name, ' ||
-- remove job.name and replace it by null so don't need to change everything
--                   'people.first_name, people.full_name, people.email_address, job.name, ' ||
                   'people.first_name, people.full_name, people.email_address, null, ' ||
                   'sales_group.name, manage_group.sales_group_id, manage_group.name ';
    return l_select_cl;


  End get_salesmem_gen_select;

  Function get_salesmem_gen_select_w_grp return Varchar2 IS

    l_select_cl Varchar2(500);

  Begin
    l_select_cl := 'Select ' ||
                   'force.salesforce_id, force.type, force.start_date_active, force.end_date_active, ' ||
                   'force.employee_person_id, force.sales_group_id, force.Partner_address_id, ' ||
                   'force.partner_customer_id, people.last_name, ' ||
                   'people.first_name, people.full_name, people.email_address, null, ' ||
                   'sales_group.name, manage_group.sales_group_id, manage_group.name ';
    return l_select_cl;

  End get_salesmem_gen_select_w_grp;

Function get_salesmem_gen_where(p_sales_member_rec IN AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type)
    return Varchar2  IS

    l_where_cl Varchar2(1000);

  Begin

-- fix bug 1265779, remove PER_ASSIGNMENTS_F, PER_JOBS
--    l_where_cl :=  'From per_jobs job, per_assignments_f assign, PER_PEOPLE_F people, ' ||
    l_where_cl :=  'From PER_PEOPLE_F people, ' ||
                   'as_sales_groups_v sales_group, AS_SALESFORCE_V force, as_sales_groups_v manage_group  ';

    If (p_sales_member_rec.user_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || ', FND_USER fnd_user ' ||
        'where fnd_user.employee_id = force.employee_person_id and ' ||
        'fnd_user.user_id = :p_user_id ';
    Else
        l_where_cl := l_where_cl || 'Where 1=1 ';
    End if;
    -- Fix bug 788241
    l_where_cl := l_where_cl || 'And force.employee_person_id = people.person_id ' ||
               ' and sales_group.sales_group_id (+) = force.sales_group_id ' ||
-- fix bug 1265779, remove PER_ASSIGNMENTS_F, PER_JOBS join
--               ' and people.person_id = assign.person_id and assign.job_id = job.job_id ' ||
--               ' and assign.assignment_type = ''E'' and assign.primary_flag = ''Y'' ' ||
               ' and force.employee_person_id = manage_group.manager_person_id(+)' ||
		' and  trunc(sysdate) >=  nvl(people.effective_start_date,trunc(sysdate)) '||
             ' and trunc(sysdate) <= nvl(people.effective_end_date,trunc(sysdate))';
    If (p_sales_member_rec.salesforce_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.salesforce_id like :p_salesforce_id ';
    End if;

    If (p_sales_member_rec.Employee_Person_Id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.Employee_Person_Id = :p_Employee_Person_Id ';
    End if;

    If (p_sales_member_rec.sales_group_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.sales_group_id = :p_sales_group_id ';
    End if;

    If (p_sales_member_rec.Partner_Address_Id <> FND_API.G_MISS_NUM) Then
       l_where_cl := l_where_cl || 'And force.Partner_Address_Id = :p_Partner_Address_Id ';
    End if;

    If (p_sales_member_rec.Partner_Customer_Id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.Partner_Customer_Id = :p_Partner_Customer_Id ';
    End if;

    If (p_sales_member_rec.Last_name <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.Last_name like :p_Last_name ';
    End if;

    If (p_sales_member_rec.first_name <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.first_name like :p_first_name ';
    End if;

    If (p_sales_member_rec.Email_address <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.Email_address like :p_Email_address ';
    End if;

    If (p_sales_member_rec.type <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And force.type = :p_type ';
    End if;

    return l_where_cl;

  End get_salesmem_gen_where;

Function get_salesmem_gen_where_w_grp(p_sales_member_rec IN AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type)
    return Varchar2  IS

    l_where_cl Varchar2(1000);

  Begin

    l_where_cl :=  'From PER_PEOPLE_F people, ' ||
                   'as_sales_groups_v sales_group, AS_FC_SALESFORCE_V force, as_sales_groups_v manage_group  ';

    If (p_sales_member_rec.user_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || ', FND_USER fnd_user ' ||
        'where fnd_user.employee_id = force.employee_person_id and ' ||
        'fnd_user.user_id = :p_user_id ';
    Else
        l_where_cl := l_where_cl || 'Where 1=1 ';
    End if;
    l_where_cl := l_where_cl || 'And force.employee_person_id = people.person_id ' ||
               ' and sales_group.sales_group_id (+) = force.sales_group_id ' ||
               ' and force.employee_person_id = manage_group.manager_person_id(+)' ||
		' and  trunc(sysdate) >=  nvl(people.effective_start_date,trunc(sysdate)) '||
             ' and trunc(sysdate) <= nvl(people.effective_end_date,trunc(sysdate))';
    If (p_sales_member_rec.salesforce_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.salesforce_id like :p_salesforce_id ';
    End if;

    If (p_sales_member_rec.Employee_Person_Id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.Employee_Person_Id = :p_Employee_Person_Id ';
    End if;

    If (p_sales_member_rec.sales_group_id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.sales_group_id = :p_sales_group_id ';
    End if;

    If (p_sales_member_rec.Partner_Address_Id <> FND_API.G_MISS_NUM) Then
       l_where_cl := l_where_cl || 'And force.Partner_Address_Id = :p_Partner_Address_Id ';
    End if;

    If (p_sales_member_rec.Partner_Customer_Id <> FND_API.G_MISS_NUM) Then
        l_where_cl := l_where_cl || 'And force.Partner_Customer_Id = :p_Partner_Customer_Id ';
    End if;

    If (p_sales_member_rec.Last_name <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.Last_name like :p_Last_name ';
    End if;

    If (p_sales_member_rec.first_name <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.first_name like :p_first_name ';
    End if;

    If (p_sales_member_rec.Email_address <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And people.Email_address like :p_Email_address ';
    End if;

    If (p_sales_member_rec.type <> FND_API.G_MISS_CHAR) Then
        l_where_cl := l_where_cl || 'And force.type = :p_type ';
    End if;

    return l_where_cl;

  End get_salesmem_gen_where_w_grp;

Procedure get_salesmem_define_cols(p_cur_get_salesmember IN Number) IS

    l_sales_member_rec AS_sales_member_PUB.sales_member_Rec_Type;

  Begin

    dbms_sql.define_column(p_cur_get_salesmember, 1, l_sales_member_rec.salesforce_id);
    dbms_sql.define_column(p_cur_get_salesmember, 2, l_sales_member_rec.type, 30);
    dbms_sql.define_column(p_cur_get_salesmember, 3, l_sales_member_rec.start_date_active);
    dbms_sql.define_column(p_cur_get_salesmember, 4, l_sales_member_rec.end_date_active);
    dbms_sql.define_column(p_cur_get_salesmember, 5, l_sales_member_rec.employee_person_id);
    dbms_sql.define_column(p_cur_get_salesmember, 6, l_sales_member_rec.sales_group_id);
    dbms_sql.define_column(p_cur_get_salesmember, 7, l_sales_member_rec.partner_address_id);
    dbms_sql.define_column(p_cur_get_salesmember, 8, l_sales_member_rec.partner_customer_id);
    --dbms_sql.define_column(p_cur_get_salesmember, 9, l_sales_member_rec.partner_contact_id);
    dbms_sql.define_column(p_cur_get_salesmember, 9, l_sales_member_rec.last_name, 40);
    dbms_sql.define_column(p_cur_get_salesmember, 10, l_sales_member_rec.first_name, 20);
    dbms_sql.define_column(p_cur_get_salesmember, 11, l_sales_member_rec.full_name, 240);
    dbms_sql.define_column(p_cur_get_salesmember, 12, l_sales_member_rec.email_address, 240);
    dbms_sql.define_column(p_cur_get_salesmember, 13, l_sales_member_rec.job_title, 240);
    dbms_sql.define_column(p_cur_get_salesmember, 14, l_sales_member_rec.sales_group_name, 60);
    dbms_sql.define_column(p_cur_get_salesmember, 15, l_sales_member_rec.managing_sales_grp_id);
    dbms_sql.define_column(p_cur_get_salesmember, 16, l_sales_member_rec.managing_sales_grp_name, 60);
  End get_salesmem_define_cols;

Procedure get_salesmem_bind_vars(p_cur_get_salesmember IN Number,
                             p_sales_member_rec IN AS_sales_member_PUB.sales_member_Rec_Type) IS

  Begin
    If (p_sales_member_rec.user_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_user_id',
            p_sales_member_rec.user_id);
    End if;

    If (p_sales_member_rec.salesforce_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_salesforce_id',
            p_sales_member_rec.salesforce_id);
    End if;

    If (p_sales_member_rec.employee_person_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_employee_person_id',
            p_sales_member_rec.employee_person_id);
    End if;

    If (p_sales_member_rec.sales_group_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_sales_group_id',
            p_sales_member_rec.sales_group_id);
    End if;


    If (p_sales_member_rec.partner_address_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_partner_address_id',
            p_sales_member_rec.partner_address_id);
    End if;

    If (p_sales_member_rec.partner_customer_id <> FND_API.G_MISS_NUM) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_partner_customer_id',
            p_sales_member_rec.partner_customer_id);
    End if;

    If (p_sales_member_rec.last_name <> FND_API.G_MISS_CHAR) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_last_name',
            p_sales_member_rec.last_name);
    End if;

    If (p_sales_member_rec.first_name <> FND_API.G_MISS_CHAR) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_first_name',
            p_sales_member_rec.first_name);
    End if;

    If (p_sales_member_rec.email_address <> FND_API.G_MISS_CHAR) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_email_address',
            p_sales_member_rec.email_address);
    End if;

    If (p_sales_member_rec.type <> FND_API.G_MISS_CHAR) Then
        dbms_sql.bind_variable(p_cur_get_salesmember, 'p_type',
            p_sales_member_rec.type);
    End if;

  End get_salesmem_bind_vars;

Procedure get_salesmem_column_values(p_cur_get_salesmember IN Number,
                            x_sales_member_rec OUT NOCOPY AS_sales_member_PUB.sales_member_Rec_Type) IS

  Begin

    dbms_sql.column_value(p_cur_get_salesmember, 1, x_sales_member_rec.salesforce_id);
    dbms_sql.column_value(p_cur_get_salesmember, 2, x_sales_member_rec.type);
    dbms_sql.column_value(p_cur_get_salesmember, 3, x_sales_member_rec.start_date_active);
    dbms_sql.column_value(p_cur_get_salesmember, 4, x_sales_member_rec.end_date_active);
    dbms_sql.column_value(p_cur_get_salesmember, 5, x_sales_member_rec.employee_person_id);
    dbms_sql.column_value(p_cur_get_salesmember, 6, x_sales_member_rec.sales_group_id);
    dbms_sql.column_value(p_cur_get_salesmember, 7, x_sales_member_rec.partner_address_id);
    dbms_sql.column_value(p_cur_get_salesmember, 8, x_sales_member_rec.partner_customer_id);
    --dbms_sql.column_value(p_cur_get_salesmember, 9, x_sales_member_rec.partner_contact_id);
    dbms_sql.column_value(p_cur_get_salesmember, 9, x_sales_member_rec.last_name);
    dbms_sql.column_value(p_cur_get_salesmember, 10, x_sales_member_rec.first_name);
    dbms_sql.column_value(p_cur_get_salesmember, 11, x_sales_member_rec.full_name);
    dbms_sql.column_value(p_cur_get_salesmember, 12, x_sales_member_rec.email_address);
    dbms_sql.column_value(p_cur_get_salesmember, 13, x_sales_member_rec.job_title);
    dbms_sql.column_value(p_cur_get_salesmember, 14, x_sales_member_rec.sales_group_name);
    dbms_sql.column_value(p_cur_get_salesmember, 15, x_sales_member_rec.managing_sales_grp_id);
    dbms_sql.column_value(p_cur_get_salesmember, 16, x_sales_member_rec.managing_sales_grp_name);

  End get_salesmem_column_values;

  /*****************************************************************************************/
  /************    PUBLIC PROCEDURES                                                    ****/
  /*****************************************************************************************/

  --
  -- NAME
  --   Get_Sales_groups
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  --
  -- HISTORY
  --
  --
PROCEDURE Get_Sales_groups
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2 := FND_API.G_FALSE,
    p_SALES_GROUP_rec                      IN     AS_SALES_GROUP_PUB.SALES_GROUP_rec_Type,
    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_SALES_GROUP_tbl                      OUT NOCOPY    AS_SALES_GROUP_PUB.SALES_GROUP_tbl_Type ) IS


    l_api_name            CONSTANT VARCHAR2(30) := 'Get_Sales_groups';
    l_api_version_number  CONSTANT NUMBER   := 2.0;

    l_SALES_GROUP_rec     AS_SALES_GROUP_PUB.SALES_GROUP_rec_type;
    l_rec_count           Number := 0;
    l_select_cl           Varchar2(500);
    l_where_cl            Varchar2(1000);
    l_cur_get_salesgroup  Number;
    l_ignore              Number;
    l_curr_row            Number := 0;
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.sompv.Get_Sales_groups';

BEGIN


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
         IF l_debug THEN
         	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT.Get_Sales_groups - BEGIN');
         END IF;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body

    Begin

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Open Cursor');
           END IF;
      END IF;

      l_cur_get_salesgroup := DBMS_SQL.open_cursor;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Generate Select');
	   END IF;
      END IF;

      l_select_cl := get_sales_group_gen_select;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Generate Where');
           END IF;
      END IF;

      l_where_cl := get_sales_group_gen_where(p_sales_group_rec);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Parse SQL');
           END IF;
      END IF;

      DBMS_SQL.parse(l_cur_get_salesgroup,
                     l_select_cl || l_where_cl, DBMS_SQL.native);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Define Columns');
          END IF;
      END IF;

      get_sales_group_define_columns(l_cur_get_salesgroup);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Bind Variables');
	   END IF;
      END IF;

      get_sales_group_bind_variables(l_cur_get_salesgroup, p_sales_group_rec);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Execute SQL');
	   END IF;
      END IF;

      l_ignore := DBMS_SQL.Execute(l_cur_get_salesgroup);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Column Values');
           END IF;
      END IF;

      Loop
          If (dbms_sql.fetch_rows(l_cur_get_salesgroup) > 0) Then
              get_sales_group_column_values(l_cur_get_salesgroup, l_SALES_GROUP_rec);
              l_curr_row := l_curr_row + 1;
              x_SALES_GROUP_tbl(l_curr_row) := l_SALES_GROUP_rec;
          Else
              Exit;
          End if;
      End Loop;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Close cursor');
	   END IF;
      END IF;

      DBMS_SQL.Close_Cursor(l_cur_get_salesgroup);


    EXCEPTION

          WHEN NO_DATA_FOUND THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      --FND_MESSAGE.Set_Name('AS', 'Pvt Pipeline API: Cannot find salesgroup'); -- MMSG
                      --FND_MSG_PUB.ADD;
                      IF l_debug THEN
                      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,  'AS_SALES_ORG_MANAGER_PVT: Cannot find sales group');
                      END IF;
          END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
          return;
    End;

      -- End of API body.
      --

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT.Get_Sales_groups End');
           END IF;
          --FND_MESSAGE.Set_Name('AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser End');
          --FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data          =>      x_msg_data
      );


  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Get_Sales_groups;

  --
  -- NAME
  --   Get_CurrentUser
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --   This procedure is used to do two things
  --   1) Get salesforce_id, employee_id, partner_customer_id ....
  --   2) Validate against user_id to make sure the login person is a valid user
  --   So, that's the reason why checking user_id first and then salesforce_id
  --
  -- HISTORY
  --
  --
PROCEDURE Get_CurrentUser
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_salesforce_id                        IN     NUMBER,
    p_admin_group_id                       IN    NUMBER,
    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_sales_member_rec                     OUT NOCOPY    AS_SALES_MEMBER_PUB.Sales_member_rec_Type ) IS


    Cursor C_GetIdentity_FndUser(p_user_id Number) IS
              Select     force.resource_id,
                         force.category,
                         force.start_date_active,
                         force.end_date_active,
                         decode(force.category,'EMPLOYEE',force.source_id,null),
                         null,
                         null,
                         decode(force.category,'PARTY',force.source_id,null)
              From JTF_RS_RESOURCE_EXTNS force, JTF_RS_ROLE_RELATIONS rrel
			   ,JTF_RS_ROLES_B roleb, FND_User fnd_user
              Where force.user_id = fnd_user.user_id
              and fnd_user.user_id = p_user_id
	         and force.category in ('EMPLOYEE','PARTY')
		    and force.resource_id = rrel.role_resource_id
		    and rrel.role_resource_type = 'RS_INDIVIDUAL'
		    and rrel.role_id = roleb.role_id
		    and roleb.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
		    and rownum = 1;

    Cursor C_GetIdentity_SFID(p_salesforce_id Number) IS
              Select     force.salesforce_id,
                         force.Type,
                         force.start_date_active,
                         force.end_date_active,
                         force.employee_person_id,
                   --      force.sales_group_id,
                         force.partner_address_id,
                         force.partner_customer_id,
                         force.partner_contact_id
              From AS_SALESFORCE_V force
              Where salesforce_id = p_salesforce_id
		    and rownum = 1;

    Cursor C_GetAdminGroup(p_salesforce_id NUMBER, p_sales_group_id NUMBER) IS
		    Select 1
		    from dual
		    where exists(select 1 from AS_FC_SALESFORCE_V force
		                 where salesforce_id = p_salesforce_id
					  and sales_group_id = p_sales_group_id);

    l_found          NUMBER;
    check_salesforce_id NUMBER;

    l_api_name    CONSTANT VARCHAR2(30) := 'Get_CurrentUser';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.sompv.Get_CurrentUser';

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
         IF l_debug THEN
         	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT.Get_CurrentUser - BEGIN');
	 END IF;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body

    Begin

	-- re-initializing this variable due to weird bug. this valus is lost when the package is called
      IF (FND_GLOBAL.User_Id < 0) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
              FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;

          open C_GetIdentity_SFID(p_salesforce_id);
          Fetch C_GetIdentity_SFID Into x_sales_member_rec.salesforce_id,
                                        x_sales_member_rec.type,
                                        x_sales_member_rec.start_date_active,
                                        x_sales_member_rec.end_date_active,
                                        x_sales_member_rec.employee_person_id,
                 --                       x_sales_member_rec.sales_group_id,
                                        x_sales_member_rec.partner_address_id,
                                        x_sales_member_rec.partner_customer_id,
                                        x_sales_member_rec.partner_contact_id;
          Close C_GetIdentity_SFID;
          -- RAISE FND_API.G_EXC_ERROR;
      Else
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             IF l_debug THEN
             	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT - Using FndUser to find identity');
             END IF;
          END IF;

          Open C_GetIdentity_FndUser(FND_GLOBAL.User_Id);

          If (C_GetIdentity_FndUser%ROWCOUNT > 1) Then

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                  --FND_MESSAGE.Set_Name('AS', 'Pvt Pipeline API: Found duplicated salesrep'); -- MMSG
                  --FND_MSG_PUB.ADD;
                   IF l_debug THEN
                   	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT - Found duplicated salesrep');
                   END IF;
              END IF;
          End if;
          Fetch C_GetIdentity_FndUser Into x_sales_member_rec.salesforce_id,
                                           x_sales_member_rec.type,
                                           x_sales_member_rec.start_date_active,
                                           x_sales_member_rec.end_date_active,
                                           x_sales_member_rec.employee_person_id,
              --                             x_sales_member_rec.sales_group_id,
                                           x_sales_member_rec.partner_address_id,
                                           x_sales_member_rec.partner_customer_id,
                                           x_sales_member_rec.partner_contact_id;
          Close C_GetIdentity_FndUser;

          -- raise error if salesforce_id is null
          If (x_sales_member_rec.salesforce_id is null OR x_sales_member_rec.salesforce_id = FND_API.G_MISS_NUM) Then
              FND_MESSAGE.Set_Name('AS', 'AS_INVALID_USER_ID');
              FND_MESSAGE.Set_Token('VALUE', FND_GLOBAL.USER_ID, FALSE);
              FND_MSG_PUB.ADD;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                   IF l_debug THEN
                   	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT - Cannot identify user by checking user_id at JTF resource');
                   END IF;
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
              return;
          End if;

      END IF;

	 check_salesforce_id := x_sales_member_rec.salesforce_id;

	 IF (p_admin_group_id IS NOT NULL and p_admin_group_id <> FND_API.G_MISS_NUM) THEN
	    open C_GetAdminGroup(check_salesforce_id, p_admin_group_id);
	    fetch C_GetAdminGroup into l_found;
	    IF(C_GetAdminGroup%NOTFOUND) THEN
		  close C_GetAdminGroup;
		  RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    close C_GetAdminGroup;
      END IF;

      x_sales_member_rec.user_id := FND_GLOBAL.User_Id;

    EXCEPTION

          WHEN NO_DATA_FOUND THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      --FND_MESSAGE.Set_Name('AS', 'Pvt Pipeline API: Cannot find salesrep'); -- MMSG
                      --FND_MSG_PUB.ADD;
                      IF l_debug THEN
                      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,  'AS_SALES_MEMBER_PVT: Cannot identify user');
                      END IF;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
            return;

    End;

      -- End of API body.
      --

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT.Get_CurrentUser End');
           END IF;
          --FND_MESSAGE.Set_Name('AS_SALES_MEMBER_PVT.Get_CurrentUser End');
          --FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data          =>      x_msg_data
      );


  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Get_CurrentUser;

--
  -- NAME
  --   Get_Salesreps
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  --
  -- HISTORY
  --
  --
PROCEDURE Get_Sales_members
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_sales_member_rec                     IN     AS_SALES_MEMBER_PUB.Sales_member_rec_Type,
    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_sales_member_tbl                     OUT NOCOPY    AS_SALES_MEMBER_PUB.Sales_member_tbl_Type ) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'Get_Sales_members';
    l_api_version_number  CONSTANT NUMBER   := 2.0;

    l_sales_member_rec    AS_SALES_MEMBER_PUB.Sales_member_rec_type;
    l_rec_count           Number := 1;

    Cursor C_GetGroupExist(p_salesforce_id NUMBER) IS
	  select 1
	  from dual
	  where exists(select 1 from AS_FC_SALESFORCE_V sale
	               where sale.salesforce_id = p_salesforce_id);

    l_found               NUMBER;

    l_rec_count           Number := 0;
    l_select_cl           Varchar2(500);
    l_where_cl            Varchar2(1000);
    l_cur_get_salesmember  Number;
    l_ignore              Number;
    l_curr_row            Number := 0;
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.sompv.Get_Sales_members';

BEGIN


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
         IF l_debug THEN
         	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT.Get_Sales_Members - BEGIN');
         END IF;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body

    Begin

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Open Cursor');
           END IF;
      END IF;

      l_cur_get_salesmember := DBMS_SQL.open_cursor;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,  'AS_SALES_ORG_MANAGER_PVT - Generate Select');
          END IF;
      END IF;

	 open C_GetGroupExist(p_sales_member_rec.salesforce_id);
	 fetch C_GetGroupExist into l_found;
	 IF(C_GetGroupExist%NOTFOUND) THEN
         l_select_cl := get_salesmem_gen_select;
	 ELSE
         l_select_cl := get_salesmem_gen_select_w_grp;
	 END IF;
	 close C_GetGroupExist;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           IF l_debug THEN
           	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Generate Where');
           END IF;
      END IF;

	 open C_GetGroupExist(p_sales_member_rec.salesforce_id);
	 fetch C_GetGroupExist into l_found;
	 IF(C_GetGroupExist%NOTFOUND) THEN
         l_where_cl := get_salesmem_gen_where(p_sales_member_rec);
	 ELSE
         l_where_cl := get_salesmem_gen_where_w_grp(p_sales_member_rec);
	 END IF;
	 close C_GetGroupExist;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_ORG_MANAGER_PVT - Parse SQL');
          END IF;
      END IF;


      DBMS_SQL.parse(l_cur_get_salesmember,
                     l_select_cl || l_where_cl, DBMS_SQL.native);


      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Define Columns');
          END IF;
      END IF;

      get_salesmem_define_cols(l_cur_get_salesmember);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Bind Variables');
          END IF;
      END IF;

      get_salesmem_bind_vars(l_cur_get_salesmember, p_sales_member_rec);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Execute SQL');
          END IF;
      END IF;

      l_ignore := DBMS_SQL.Execute(l_cur_get_salesmember);

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Column Values');
          END IF;
      END IF;


      -- initializing return status as this is always come up as 'S'
      x_return_status := FND_API.G_RET_STS_ERROR;
      Loop
          If (dbms_sql.fetch_rows(l_cur_get_salesmember) > 0) Then
              get_salesmem_column_values(l_cur_get_salesmember, l_sales_member_rec);
              l_curr_row := l_curr_row + 1;
              x_sales_member_tbl(l_curr_row) := l_sales_member_rec;
	      x_return_status := FND_API.G_RET_STS_SUCCESS;
          Else
              Exit;
          End if;
      End Loop;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         IF l_debug THEN
         	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_ORG_MANAGER_PVT - Close cursor');
         END IF;
      END IF;

      DBMS_SQL.Close_Cursor(l_cur_get_salesmember);

    EXCEPTION

          WHEN NO_DATA_FOUND THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      --FND_MESSAGE.Set_Name('AS', 'Pvt Pipeline API: Cannot find salesrep'); -- MMSG
                      --FND_MSG_PUB.ADD;
                      IF l_debug THEN
                      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PVT: Cannot find user');
                      END IF;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );

      return;

   End; --end for the above block

      -- End of API body.
      --

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PVT.Get_Sales_Members End');
         END IF;
          --FND_MESSAGE.Set_Name('AS_SALES_MEMBER_PVT.Get_CurrentUser End');
          --FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data          =>      x_msg_data
      );


  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
          ,P_ROLLBACK_FLAG  => 'N'
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Get_Sales_members;

-- Start of Comments
--
--    Function name : Get_Sales_Relation
--    Type        : Private
--    Function    : Return relation between two sales: Firstline manager(G_FIRSTLINE_MANAGER)
--		    higher level manager(G_HIGHER_MANAGER) and no relationship between them
--		    (G_NO_RELATION).
--
--    Pre-reqs    : None
--    Paramaeters    :
--	p_identity_salesforce_id	IN NUMBER	Required
--	p_salesrep_salesforce_id	IN NUMBER	Optional
--			DEFAULT FND_API.G_MISS_NUM
--    Version    :
--
--
--    Note :
--	Cases:
--	  1. If p_salesrep_salesforce_id is NULL or FND_API.G_MISS_NUM, this function will
--	     take p_identity_salesforce_id as a root and check all relations under it and
--	     determine if p_identity_salesforce_id is the firstline manager or not.
--	  2. If p_salesrep_salesforce_id is not NULL, the function will only check the
--	     relation between them.
--	Example:
--	  Give the relation map like this:
--				Manager A
--				   |
--				  / \
--			         /   \
--		        Sales rep B  Manager C
--     				      |
--				     Sales rep D
--	 For above example, if you pass in Manager A as p_identity_salesforce_id, and not pass in
--	 p_salesrep_salesforce_id, Manager A will be higher level manager
--	 if you pass in Manager A as p_identity_salesforce_id, and Sales rep B as p_salesrep_salesforce_id
--	 Manager A will be firstline manager.
/*
FUNCTION Get_Sales_Relations
(   p_identity_salesforce_id	IN NUMBER,
    p_salesrep_salesforce_id	IN NUMBER DEFAULT FND_API.G_MISS_NUM
 ) RETURN NUMBER IS

 CURSOR l_manager_sales_rel_csr (c_manager_id NUMBER, c_sales_id NUMBER) IS
    SELECT rm.reports_to_flag reports_to_flag
    FROM as_rep_managers_v rm, as_salesforce_v sf1, as_salesforce_v sf2
    WHERE rm.manager_person_id = sf1.employee_person_id
	AND rm.person_id = sf2.employee_person_id
	AND sf1.salesforce_id = c_manager_id
	AND sf2.salesforce_id = c_sales_id;

 CURSOR l_sales_org_csr (c_manager_id NUMBER) IS
    SELECT rm.reports_to_flag reports_to_flag
    FROM as_rep_managers_v rm, as_salesforce_v sf
    WHERE rm.manager_person_id = sf.employee_person_id
	AND rm.person_id <> sf.employee_person_id
	AND sf.salesforce_id = c_manager_id;

 l_sales_relations NUMBER;
 l_flag		   VARCHAR2(1);
 l_counter	   NUMBER := 0;
BEGIN
  IF (p_salesrep_salesforce_id IS NULL OR p_salesrep_salesforce_id = FND_API.G_MISS_NUM) THEN
     l_sales_relations := G_SALESREP;
     FOR l_reports_to_flag IN l_sales_org_csr(p_identity_salesforce_id) LOOP
	 l_counter := l_counter + 1;
	 IF l_reports_to_flag.reports_to_flag = 'N' THEN
	    l_sales_relations := G_HIGHER_MANAGER;
	    EXIT;
	   Elsif l_reports_to_flag.reports_to_flag = 'Y' THEN
	    l_sales_relations := G_FIRSTLINE_MANAGER;
	 END IF;
     END LOOP;
    Else
     IF (p_identity_salesforce_id = p_salesrep_salesforce_id) THEN
        l_sales_relations := G_IDENTICAL_SALESFORCE;
       Else
	OPEN l_manager_sales_rel_csr(p_identity_salesforce_id, p_salesrep_salesforce_id);
	FETCH l_manager_sales_rel_csr INTO l_flag;
	IF l_manager_sales_rel_csr%NOTFOUND THEN
	   l_sales_relations := G_NO_RELATION;
	  Elsif (l_flag = 'Y') THEN
	   l_sales_relations := G_FIRSTLINE_MANAGER;
	  Else
	   l_sales_relations := G_HIGHER_MANAGER;
	END IF;
	CLOSE l_manager_sales_rel_csr;
     END IF;
  END IF;
  RETURN l_sales_relations;
END Get_Sales_Relations;
*/
-- This function is to fix bug 855326
-- Check what the relation between a salesforce and a sales group
-- The possible return value is
--  E -- The salesforce is a salesrep in this sales group
--  M -- The salesforce is a manager for this sales group
--  A -- The salesforce is a administrator for this sales group
--  N -- The salesforce is no relation with this sales group
FUNCTION Get_Member_Role(p_salesforce_id NUMBER,
			   p_sales_group_id NUMBER) RETURN VARCHAR2 IS
     -- change to use jtf_rs_group_members
	CURSOR l_employee_role_cursor(c_salesforce_id NUMBER,
				      c_sales_group_id NUMBER) IS
		SELECT 'Y'
		FROM jtf_rs_group_members mem, jtf_rs_role_relations rrel, jtf_rs_roles_b role
		WHERE rrel.role_id = role.role_id
		and role.member_flag = 'Y'
		and rrel.role_resource_id = mem.group_member_id
		and mem.resource_id = c_salesforce_id
		and group_id IN
		   (SELECT  parent_group_id
		    FROM jtf_rs_groups_denorm
		    WHERE group_id = c_sales_group_id);
     -- Change to use jtf_rs_group_members, jtf_rs_roles_b and jtf_rs_role_relations
	CURSOR l_manager_role_cursor(c_salesforce_id NUMBER,
				      c_sales_group_id NUMBER) IS
		SELECT 'Y'
		FROM jtf_rs_group_members mem, jtf_rs_role_relations rrel, jtf_rs_roles_b role
		WHERE rrel.role_id = role.role_id
		and role.manager_flag = 'Y'
		and rrel.role_resource_id = mem.group_member_id
		and mem.resource_id = c_salesforce_id
		and group_id IN
		   (SELECT  parent_group_id
		    FROM jtf_rs_groups_denorm
		    WHERE group_id = c_sales_group_id);
	CURSOR l_admin_role_cursor(c_salesforce_id NUMBER,
				      c_sales_group_id NUMBER) IS
		SELECT 'Y'
		FROM jtf_rs_group_members mem, jtf_rs_role_relations rrel, jtf_rs_roles_b role
		WHERE rrel.role_id = role.role_id
		and role.admin_flag = 'Y'
		and rrel.role_resource_id = mem.group_member_id
		and mem.resource_id = c_salesforce_id
		and group_id IN
		   (SELECT  parent_group_id
		    FROM jtf_rs_groups_denorm
		    WHERE group_id = c_sales_group_id);
	l_member_role VARCHAR2(1);
	l_flag VARCHAR2(1);
  BEGIN
	l_member_role := 'N';
	OPEN l_employee_role_cursor(p_salesforce_id, p_sales_group_id);
	FETCH l_employee_role_cursor INTO l_flag;
	IF l_employee_role_cursor%FOUND THEN
	   l_member_role := 'E';
	END IF;
	CLOSE l_employee_role_cursor;
	OPEN l_manager_role_cursor(p_salesforce_id, p_sales_group_id);
	FETCH l_manager_role_cursor INTO l_flag;
	IF l_manager_role_cursor%FOUND THEN
	   l_member_role := 'M';
	END IF;
	CLOSE l_manager_role_cursor;
	OPEN l_admin_role_cursor(p_salesforce_id, p_sales_group_id);
	FETCH l_admin_role_cursor INTO l_flag;
	IF l_admin_role_cursor%FOUND THEN
	   l_member_role := 'A';
	END IF;
	CLOSE l_admin_role_cursor;
	RETURN l_member_role;
END Get_Member_Role;

END AS_SALES_ORG_MANAGER_PVT;

/
