--------------------------------------------------------
--  DDL for Package Body FA_CUA_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HIERARCHY_PKG" AS
/* $Header: FACHRAHMB.pls 120.1.12010000.3 2009/08/20 14:17:51 bridgway ship $ */

-- Creating Package Body for FA_CUA_HIERARCHY_PKG
-- Private APIs

Function Validate_hierarchy_purpose(x_purpose_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
Cursor C_1 is select asset_hierarchy_purpose_id
              from fa_asset_hierarchy_purpose
              where asset_hierarchy_purpose_id = x_purpose_id;
l_purpose_id  FA_ASSET_HIERARCHY_PURPOSE.asset_hierarchy_purpose_id%TYPE;
Begin
  open C_1;
  fetch C_1 into l_purpose_id;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_hierarchy_purpose;

--Procedure to validate Asset CAtegory
Procedure Validate_asset_category (x_book_type_code   in varchar2
                        ,x_asset_category_id          in number
                        ,x_lease_id                   in NUMBER
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null)
is
Cursor C_1 is select category_type
              from fa_categories
              where category_id = x_asset_category_id;

Cursor C_2 is select 1
              from fa_category_books
              where category_id = x_asset_category_id
              and book_type_code = x_book_type_code;

l_category_type  FA_CATEGORIES.category_type%TYPE;
dummy C_2%ROWTYPE;
l_old_err_stack  varchar2(640);
Begin
 l_old_err_stack := x_err_stack;
 x_err_stack := x_err_stack||'->'||'Validating_Asset_CAtegory';
 x_err_stage := 'Validating existance of Category';
 open C_1;
  fetch C_1 into l_category_type;
  if C_1%NOTFOUND then
     close C_1;
     x_err_code := 'CUA_INVALID_CATEGORY';
     return ;
  else
      close C_1;
      x_err_stage := 'Validating Category with Lease';
     if(x_lease_id is not null AND l_category_type = 'NON-LEASE') then
        x_err_code := 'CUA_INVALID_CATEGORY_LEASE';
        return;
     end if;
  end if;
  x_err_stage := 'Validating Category defined for the Book';
  Open C_2;
  fetch C_2 into dummy;
  if(C_2%NOTFOUND) then
    x_err_code := 'CUA_INVALID_CATG_BOOK';
    close C_2;
    return;
  end if;
  close C_2;
x_err_stack := l_old_err_stack;
End Validate_asset_category;

 --Function to Validate the Lease ID
Function Validate_lease(x_lease_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null)
return Boolean
is
Cursor C_1 is select lease_id
              from fa_leases
              where lease_id = x_lease_id;
l_lease_id  number;
Begin
  open C_1;
  fetch C_1 into l_lease_id;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_lease;

--Fnction to validate Asset Key words
Function Validate_asset_key(x_asset_key_ccid in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null)
return Boolean
is
Cursor C_1 is select code_combination_id
              from fa_asset_keywords
              where code_combination_id = x_asset_key_ccid;
l_asset_key_ccid  number;
Begin
  open C_1;
  fetch C_1 into l_asset_key_ccid;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_asset_key;

--Fnction to validate Location
Function Validate_location(x_location_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null)
return Boolean
is
Cursor C_1 is select location_id
              from fa_locations
              where location_id = x_location_id;
l_location_id  number;
Begin
  open C_1;
  fetch C_1 into l_location_id;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_location;

--Fnction to validate Location
Function Validate_gl_ccid(x_gl_ccid in number,x_CofA_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
Cursor C_1 is select code_combination_id
              from   gl_code_combinations
              where  code_combination_id  = x_gl_ccid
              and    chart_of_accounts_id = x_CofA_id
              and    account_type         = 'E'
              and    enabled_flag         = 'Y'
              and    summary_flag         = 'N'
              and    template_id         is null
              and    detail_posting_allowed_flag = 'Y';
l_gl_ccid  number;
Begin
  open C_1;
  fetch C_1 into l_gl_ccid;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_gl_ccid;

--Fnction to validate employee
Function Validate_employee(x_employee_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
Cursor C_1 is select employee_id
              from fa_employees
              where employee_id = x_employee_id;
l_employee_id  number;
Begin
  open C_1;
  fetch C_1 into l_employee_id;
  if C_1%NOTFOUND then
     close C_1;
     return FALSE;
  end if;
  close C_1;
  return TRUE;
End Validate_employee;

--Function to validate the distribution set
Function valid_dist_set(x_dist_set_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null)
return Boolean
is
Cursor C is select dist_set_id
            from FA_HIERARCHY_DISTRIBUTIONS
            where dist_set_id = x_dist_set_id;
l_dist_set_id    number;
Begin
  open C;
  fetch C into l_dist_set_id;
  if C%NOTFOUND then
     close C ;
     return FALSE;
  end if;
  close C;
  return TRUE;
End valid_dist_set;
Function validate_level_number(p_level_number in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return boolean
is
begin
    if (p_level_number < 0 OR
           (p_level_number - trunc(p_level_number)) > 0)
       then
          return FALSE;
    else
          return TRUE;

    end if;
end validate_level_number;

Function set_global_level_number(p_level_number in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return boolean
is
Begin
  FA_CUA_HIERARCHY_PKG.global_level_number := p_level_number;
  return TRUE;
End;

Function get_global_level_number
return number
is
BEGIN
  return (nvl(FA_CUA_HIERARCHY_PKG.global_level_number,-1));
END;
--Function  to check an hierararchy node exists
Function check_node_exists ( x_name in varchar2
                            ,x_node_type in Varchar2
                            ,x_purpose_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return Boolean
is
Cursor C_NAME is select asset_hierarchy_id
                 from fa_asset_hierarchy
                 where name = x_name
                 and asset_hierarchy_purpose_id = x_purpose_id
                 and nvl(asset_id,0) = decode(x_node_type,'N',0,asset_id);
dummy            number;
Begin
  open C_NAME;
  fetch C_NAME into dummy;
  if (C_NAME%NOTFOUND ) then
     close C_NAME;
     return FALSE;
  end if;
  close C_NAME;
  return TRUE;
END check_node_exists;

Procedure Insert_row (     x_rowid                      in out nocopy varchar2
                         , x_asset_hierarchy_purpose_id in number
                         , x_asset_hierarchy_id         in out nocopy number
                         , x_name                       in     varchar2 default null
                         , x_level_number               in number
                         , x_hierarchy_rule_set_id      in number
                         , X_CREATION_DATE              in date
                         , X_CREATED_BY                 in number
                         , X_LAST_UPDATE_DATE           in date
                         , X_LAST_UPDATED_BY            in number
                         , X_LAST_UPDATE_LOGIN          in number
                         , x_description                in varchar2
                         , x_parent_hierarchy_id        in number
                         , x_lowest_level_flag          in number
                         , x_depreciation_start_date    in date
                         , x_asset_id                   in number
                         , X_ATTRIBUTE_CATEGORY         in varchar2
                         , X_ATTRIBUTE1                 in varchar2
                         , X_ATTRIBUTE2                 in varchar2
                         , X_ATTRIBUTE3                 in varchar2
                         , X_ATTRIBUTE4                 in varchar2
                         , X_ATTRIBUTE5                 in varchar2
                         , X_ATTRIBUTE6                 in varchar2
                         , X_ATTRIBUTE7                 in varchar2
                         , X_ATTRIBUTE8                 in varchar2
                         , X_ATTRIBUTE9                 in varchar2
                         , X_ATTRIBUTE10                in varchar2
                         , X_ATTRIBUTE11                in varchar2
                         , X_ATTRIBUTE12                in varchar2
                         , X_ATTRIBUTE13                in varchar2
                         , X_ATTRIBUTE14                in varchar2
                         , X_ATTRIBUTE15                in varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
     is
      cursor C is select ROWID from FA_ASSET_HIERARCHY
      where asset_hierarchy_id = X_asset_hierarchy_id ;

      CURSOR C1 is Select FA_ASSET_HIERARCHY_S.nextval from sys.dual;
      l_name FA_ASSET_HIERARCHY.name%TYPE;
    begin
     if X_asset_hierarchy_id is null then
        open C1;
        fetch C1 into X_asset_hierarchy_id ;
        close C1;
     end if;
     --Set the Node name same as the node id if the node name is null for the non asset node
     if(    nvl(x_asset_id,0) = 0
        AND x_name is null
       ) then
       l_name := to_char(x_asset_hierarchy_id);
     end if;
  insert into FA_ASSET_HIERARCHY
    (  asset_hierarchy_purpose_id
     , asset_hierarchy_id
     , name
     , level_number
     , hierarchy_rule_set_id
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN
     , description
     , parent_hierarchy_id
     , lowest_level_flag
     , depreciation_start_date
     , asset_id
     , ATTRIBUTE_CATEGORY
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15  )
   Values
      (x_asset_hierarchy_purpose_id
     , x_asset_hierarchy_id
     , nvl(x_name,l_name)
     , x_level_number
     , x_hierarchy_rule_set_id
     , X_CREATION_DATE
     , X_CREATED_BY
     , X_LAST_UPDATE_DATE
     , X_LAST_UPDATED_BY
     , X_LAST_UPDATE_LOGIN
     , x_description
     , x_parent_hierarchy_id
     , x_lowest_level_flag
     , x_depreciation_start_date
     , x_asset_id
     , X_ATTRIBUTE_CATEGORY
     , X_ATTRIBUTE1
     , X_ATTRIBUTE2
     , X_ATTRIBUTE3
     , X_ATTRIBUTE4
     , X_ATTRIBUTE5
     , X_ATTRIBUTE6
     , X_ATTRIBUTE7
     , X_ATTRIBUTE8
     , X_ATTRIBUTE9
     , X_ATTRIBUTE10
     , X_ATTRIBUTE11
     , X_ATTRIBUTE12
     , X_ATTRIBUTE13
     , X_ATTRIBUTE14
     , X_ATTRIBUTE15    );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

/* Procedure to validate the distribution table and create the distribution
   set and the distribution lines in FA_HIERARCHY_DISTRIBUTIONS table  */
   Procedure create_distribution_set
                       ( x_dist_set_id                   out nocopy number
                        ,x_book_type_code             in     varchar2
                        ,x_distribution_tab           in     FA_CUA_HIERARCHY_PKG.distribution_tabtype
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
   is
   Cursor C is select FA_HIERARCHY_DIST_SET_S.nextval from dual;
   Cursor C_CofA_id is  select accounting_flex_structure
                     from fa_book_controls
                     where book_type_code = x_book_type_code;
    l_CofA_id  number;
    l_old_err_stack  varchar2(640);
    I BINARY_INTEGER;
    l_percent_total number;
    l_rowid  varchar2(240);
    l_distribution_id  number;
    l_CREATION_DATE  DATE    default trunc(sysdate);
    l_CREATED_BY     NUMBER  := FND_GLOBAL.USER_ID;

   Begin
     l_old_err_stack := x_err_stack;
     x_err_stack := x_err_stack||'->'||'CREATE_DIST_SET';
      --Getting Chart of Account ID for the Book
     x_err_stage := 'Getting Chart of Account ID for the Book';
     open C_CofA_id;
     fetch C_CofA_id into l_CofA_id;
     if(C_CofA_id%NOTFOUND ) then
       x_err_code:= 'CUA_NO_FLEX_STRUCTURE';
       close C_CofA_id;
       return;
     end if;
     close C_CofA_id;
     --Validate the distribution Table
       x_err_stage := 'Validating Distributions';
       FOR I in 1..x_distribution_tab.count LOOP
     --Validating Expense Account
        if(x_distribution_tab(I).code_combination_id is not null
          AND NOT validate_gl_ccid( x_distribution_tab(I).code_combination_id,l_CofA_id, p_log_level_rec) )then
          x_err_code := 'CUA_INVALID_EXPENSE_ACCOUNT';
          return;
        elsif(x_distribution_tab(I).code_combination_id is  null ) then
          x_err_code := 'CUA_EXPENSE_ACCOUNT_MANDATORY';
          return;
        end if;
     --Validate Location
        if(x_distribution_tab(I).location_id is not null
          AND NOT validate_location(x_distribution_tab(I).location_id ,
                                    p_log_level_rec) )then
          x_err_code := 'CUA_INVALID_LOCATION';
          return;
        elsif(x_distribution_tab(I).location_id is null) then
          x_err_code := 'CUA_LOCATION_MANDATORY';
          return;
        end if;
     --Validate Employee
       if(x_distribution_tab(I).assigned_to is not null
          AND NOT validate_employee( x_distribution_tab(I).assigned_to,
                                     p_log_level_rec ) )then
          x_err_code := 'CUA_INVALID_EMPLOYEE';
          return;
       end if;
     END LOOP;
   --Validate the Sum of Disrtribution % is 100
     x_err_stage := 'Validating Distribution percentage sum is 100';
     FOR I in 1..x_distribution_tab.count LOOP
       l_percent_total := nvl(l_percent_total,0) +  nvl(x_distribution_tab(I).distribution_line_percentage,0);
     END LOOP;
     if(l_percent_total <> 100) then
       x_err_code := 'CUA_INVALID_LINE_PERCENT_SUM';
       return;
     end if;

     -- If Valid create the distribution set with details and return
     -- the distribution set id
      x_err_stage := 'Fetch the next Dist Set ID';
      open C;
      fetch C into x_dist_set_id;
      close c;
      x_err_stage := 'Inserting into FA_HIERARCHY_DISTRIBUTIONS table';
      l_rowid := null;
      --dbms_output.put_line('Before Inserting Distributions');
      --dbms_output.put_line('count:'||to_char(x_distribution_tab.count));
      FOR I in 1..x_distribution_tab.count LOOP
           l_distribution_id := null;
           FA_CUA_HR_DISTRIBUTION_PKG.Insert_row (
               l_rowid
             , l_distribution_id
             , x_dist_set_id
             --, x_asset_hierarchy_purpose_id
             --, x_asset_hierarchy_id
             , x_book_type_code
             , x_distribution_tab(I).distribution_line_percentage
             , x_distribution_tab(I).code_combination_id
             , x_distribution_tab(I).location_id
             , x_distribution_tab(I).assigned_to
             , l_CREATION_DATE
             , l_CREATED_BY
             , l_CREATION_DATE
             , l_CREATED_BY
             , l_CREATED_BY
             , p_log_level_rec       );
           --dbms_output.put_line('Distribution ID:'||to_char(l_distribution_id));
          END LOOP;
   x_err_stack := l_old_err_stack;
   End create_distribution_set;

--FUnction to check Ctegory is of lease type
  Function is_catg_nonlease_type(x_catg_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
  return boolean
  is
    dummy  number;
  begin
    select 1 into dummy from dual
    where exists(select 1 from fa_categories
		 where category_id = x_catg_id
		 and   category_type = 'NON-LEASE');
    return(TRUE);
  exception
    when no_data_found then
      return(FALSE);
  end is_catg_nonlease_type;

--Procedure to Validate Node Attribute Values
--Call this procedure only for Non Asset Nodes
--and attribute values are required
/* validates for   a. Called only for Non Asset Nodes
                   b. Checks for the mandatory parameters with the controls
                   c. Attribute Book is associate of the purpose Book.
                   d. Asset Node level must be zero and Non Asset node level must be Non Zero
                   e. Check all the parameters passed are valid ones.
                   f. If catrgory is given then valid for the Attribute Book.
                   g. If category and lease are given, then category is of NON_LEASE type.
                   h. If Distribution tab is given then the sum of distribution line % is 100.
   */

Procedure validate_node_attributes
                        (x_asset_hierarchy_purpose_id in number
                        ,x_asset_hierarchy_id         in number
                        ,x_level_number               in number
                        ,x_book_type_code             in varchar2
                        ,x_asset_category_id          in number default null
                        ,x_lease_id                   in NUMBER default null
                        ,x_asset_key_ccid             in number default null
                        ,x_serial_number              in varchar2 default null
                        ,x_life_end_date              in date default null
                        ,x_dist_set_id                in number default null
                        --,x_distribution_tab           in FA_CUA_HIERARCHY_PKG.distribution_tabtype
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
is
Cursor C_MANDT_CONTROLS is
select   ASSET_HIERARCHY_PURPOSE_ID,
         LEVEL_NUMBER,
         CATEGORY_MANDATORY_FLAG,
         LEASE_MANDATORY_FLAG,
         ASSET_KEY_MANDATORY_FLAG,
         SERIAL_NUMBER_MANDATORY_FLAG,
         DISTRIBUTION_MANDATORY_FLAG,
         LIFE_END_DATE_MANDATORY_FLAG,
         DPIS_MANDATORY_FLAG,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN
from FA_HIERARCHY_CONTROLS
                         where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id
                         and level_number = x_level_number;
mand_controlrec      C_MANDT_CONTROLS%ROWTYPE;
l_old_err_stack     varchar2(640);

Begin
  --x_err_code := '0';
  l_old_err_stack := x_err_stack;
  --dbms_output.put_line('Before setting Stack');
  x_err_stack := x_err_stack ||'->'||'VALIDATING_NODE_ATTRIBUTES';
  --dbms_output.put_line('After setting Stack');

  --Validating the existance of parameters with the mandatory flags
  x_err_stage := 'Validating Parameters existance with Mandatory requirements';
  open C_MANDT_CONTROLS;
  fetch C_MANDT_CONTROLS into mand_controlrec;
  --If Controls exists then validate for mandatory parameters
  if (C_MANDT_CONTROLS%FOUND) then
     if (mand_controlrec.life_end_date_mandatory_flag = 'Y'
         and x_life_end_date is null              ) then
           x_err_code := 'CUA_LIFE_END_DATE_MANDATORY';
           close C_MANDT_CONTROLS;
           return;
     end if;

     if (mand_controlrec.category_mandatory_flag = 'Y'
         and x_asset_category_id is null              ) then
           x_err_code := 'CUA_CATEGORY_MANDATORY';
           close C_MANDT_CONTROLS;
           return;
     end if;
     --Do the Mandatory check for lease only if the given category is null
     --or the category is lease type
     if(x_asset_category_id is null
        OR (x_asset_category_id is not null
            AND NOT is_catg_nonlease_type(x_asset_category_id,
                                          p_log_level_rec)
           )
       ) then
        if (mand_controlrec.lease_mandatory_flag = 'Y'
             and x_lease_id is null              ) then
            x_err_code := 'CUA_LEASE_MANDATORY';
            close C_MANDT_CONTROLS;
            return;
        end if;
     end if;
     if (mand_controlrec.asset_key_mandatory_flag = 'Y'
         and x_asset_key_ccid is null              ) then
           x_err_code := 'CUA_ASSET_KEY_MANDATORY';
           close C_MANDT_CONTROLS;
           return;
     end if;
     if (mand_controlrec.serial_number_mandatory_flag = 'Y'
         and x_serial_number is null              ) then
           x_err_code := 'CUA_SERIAL_NUMBER_MANDATORY';
           close C_MANDT_CONTROLS;
           return;
     end if;

     if (mand_controlrec.distribution_mandatory_flag = 'Y'
         AND x_dist_set_id is null ) then
             x_err_code := 'CUA_DISTRIBUTION_MANDATORY';
             close C_MANDT_CONTROLS;
             return;
      end if;
   end if;
 --dbms_output.put_line('After Mandatory check');
 --Validating the parameters
  x_err_stage := 'Validating the Parameters';

  --valodating Hierachy purpose
  if(NOT validate_hierarchy_purpose(x_asset_hierarchy_purpose_id,
                                    p_log_level_rec) )then
    x_err_code := 'CUA_INVALID_PURPOSE';
    return;
  end if;

  --Vaidating Asset CAtegory
  x_err_stage := 'Validating asset Category';
  if(x_asset_category_id is not null ) then
 -- dbms_output.put_line('Validating Category');
    validate_asset_category (x_book_type_code
                        ,x_asset_category_id
                        ,x_lease_id
                        ,x_err_code
                        ,x_err_stage
                        ,x_err_stack
                        ,p_log_level_rec);
 --dbms_output.put_line('After Category Validation');
    if(x_err_code <> '0' ) then
       return;
    end if;
  end if;
  --Validating Lease
  x_err_stage := 'Validating Lease';
  if(x_lease_id is not null AND NOT validate_lease(x_lease_id,p_log_level_rec) )then
    x_err_code := 'CUA_INVALID_LEASE';
    return;
  end if;

  --Validating Asset Key
  x_err_stage := 'Validating Asset Key';
  if(x_asset_key_ccid is not null AND NOT validate_asset_key(x_asset_key_ccid,p_log_level_rec)) then
    x_err_code := 'CUA_INVALID_ASSET_KEY';
    return;
  end if;

  --Validate Distribution Set
  x_err_stage := 'Validating Distribution Set';
  if(x_dist_set_id is not null AND NOT valid_dist_set(x_dist_set_id,
p_log_level_rec) ) then
     x_err_code := 'CUA_INVALID_DIST_SET';
     return;
  end if;
 /** Moved to procedure create_distribution_set **
  --Validating Distributions
  if(x_distribution_tab.count > 0 ) then
    x_err_stage := 'Validating Distributions';
    FOR I in 1..x_distribution_tab.count LOOP
     --Validating Expense Account
      if(x_distribution_tab(I).code_combination_id is not null
        AND NOT validate_gl_ccid( x_distribution_tab(I).code_combination_id,l_CofA_id ) )then
        x_err_code := 'CUA_INVALID_EXPENSE_ACCOUNT';
        return;
      end if;
     --Validate Location
      if(x_distribution_tab(I).location_id is not null
        AND NOT validate_location(x_distribution_tab(I).location_id ) )then
        x_err_code := 'CUA_INVALID_LOCATION';
        return;
      end if;
     --Validate Employee
      if(x_distribution_tab(I).assigned_to is not null
        AND NOT validate_employee( x_distribution_tab(I).assigned_to ) )then
        x_err_code := 'CUA_INVALID_EMPLOYEE';
        return;
      end if;
    END LOOP;
   --Validate the Sum of Disrtribution % is 100
    x_err_stage := 'Validating Distribution percentage sum is 100';
    FOR I in 1..x_distribution_tab.count LOOP
      l_percent_total := nvl(l_percent_total,0) +  nvl(x_distribution_tab(I).distribution_line_percentage,0);
    END LOOP;
    if(l_percent_total <> 100) then
      x_err_code := 'CUA_INVALID_LINE_PERCENT_SUM';
    end if;
  end if;
  **/

End validate_node_attributes;

--Function to check name is unique
Function check_name_unique(  x_event in varchar2
                            ,x_asset_hierarchy_id in number default null
                            ,x_name in varchar2
                            ,x_asset_id in number
                            ,x_purpose_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
Cursor C_name_insert is  Select name
                         from   FA_ASSET_HIERARCHY
                         where  name = x_name
                         and    decode(nvl(asset_id,0),0,'N','A') = decode(nvl(x_asset_id,0),0,'N','A')
                         and    asset_hierarchy_purpose_id = x_purpose_id;
Cursor C_name_update is  Select name
                         from   FA_ASSET_HIERARCHY
                         where  name = x_name
                         and    decode(nvl(asset_id,0),0,'N','A') = decode(nvl(x_asset_id,0),0,'N','A')
                         and    asset_hierarchy_purpose_id = x_purpose_id
                         and    asset_hierarchy_id <> nvl(x_asset_hierarchy_id,0);
l_name fa_asset_hierarchy.name%TYPE;
Begin
   if(x_event = 'INSERT') then
  -- validate for name uniqueness if passed
  -- x_err_stage := 'Validating name uniqueness';
  -- if (x_name is not null ) then
      open C_NAME_insert;
      fetch c_name_insert into l_name;
      if(C_NAME_insert%FOUND) then
        close C_NAME_insert;
        --x_err_code := 'CUA_NAME_NOT_UNIQUE';
        return FALSE;
      end if;
      close C_NAME_insert;
      return TRUE;
   elsif(x_name = 'UPDATE') then
      open C_NAME_update;
      fetch c_name_update into l_name;
      if(C_NAME_update%FOUND) then
        close C_NAME_update;
        return FALSE;
      end if;
      close C_NAME_update;
      return TRUE;
   end if;
end check_name_unique;


Procedure validate_node( x_calling_module             in varchar2 default 'A'
                        ,x_asset_hierarchy_purpose_id in out nocopy number
                        ,x_book_type_code             in varchar2
                        ,x_name                       in varchar2 default null
                        ,x_level_number               in number default 0
                        ,x_parent_hierarchy_id        in number
                        ,x_hierarchy_rule_set_id      in number default null
                        ,x_err_code                   in out nocopy varchar2
                        ,x_err_stage                  in out nocopy varchar2
                        ,x_err_stack                  in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
is
  /* validates for a. Book is of Corporate class
                   b. parent Node exists
                   d. Book type code matches with the parent book type
                   e. Rule set book matches with the Node book
                   f. check purpose id exists if passed else return purpose ID
                   g. Check purpose book matches with book if both passed
                   h. Check either the purpose or book is passed
                   i. Level Number is 0 for asset node
                   j. Level number is a valid positive integer.
                   k. Level number is within the permissible limit
                   l. Parent level is one level higher than the current level.
                   m. Node name cannot be null for Asset node
   */
 l_old_err_stack varchar2(640);
 v_book_class FA_BOOK_CONTROLS.book_class%TYPE;
 v_book_type_code FA_BOOK_CONTROLS.book_type_code%TYPE;
 v_name FA_ASSET_HIERARCHY.name%TYPE;
 dummy number;
  l_book_type_code varchar2(30);
  v_mandatory_asset_flag varchar2(1);


 INVALID_PURPOSE  EXCEPTION;
 PARENT_MANDATORY EXCEPTION;
 BOOK_TYPE_NOT_EXISTS EXCEPTION;
 INVALID_BOOK_TYPE EXCEPTION;
 INVALID_PARENT_NODE EXCEPTION;
 INVALID_PARENT_BOOK_TYPE EXCEPTION;
 INVALID_RULE_SET EXCEPTION;
 INVALID_RULE_BOOK EXCEPTION;
 INVALID_PURPOSE_ID EXCEPTION;
 PURPOSE_NOT_EXISTS EXCEPTION;

 Cursor C_BOOK is
  Select book_class from FA_BOOK_CONTROLS
  where book_type_code = x_book_type_code;
 Cursor C_PARENT is
   select book_type_code from FA_ASSET_HIERARCHY_PURPOSE
   where asset_hierarchy_purpose_id = (Select asset_hierarchy_purpose_id
                    from fa_asset_hierarchy
            where asset_hierarchy_id = x_parent_hierarchy_id);
 Cursor C_RULE is
   Select book_type_code from FA_HIERARCHY_RULE_SET
   where hierarchy_rule_set_id = x_hierarchy_rule_set_id;
 Cursor C_PURPOSE is select asset_hierarchy_purpose_id,mandatory_asset_flag
              from FA_ASSET_HIERARCHY_PURPOSE
              where book_type_code = x_book_type_code;

 Cursor C_PERMIT_LEVELS is
 select nvl(permissible_levels,0)
 from FA_ASSET_HIERARCHY_PURPOSE
 where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id;
 v_permit_levels  FA_ASSET_HIERARCHY_PURPOSE.permissible_levels%TYPE;
 purpose_rec C_PURPOSE%ROWTYPE;

 Cursor C_PARENT_LEVEL is select level_number
                   from FA_ASSET_HIERARCHY
                   where asset_hierarchy_id = x_parent_hierarchy_id;
 v_parent_level    number;
 Begin
   x_err_code := '0';
   l_old_err_stack := x_err_stack;
   x_err_stack := x_err_stack ||'->'|| 'VALIDATING_NODE';
  --check for validity of purpose if not null
    x_err_stage := 'Validating Purpose ID';
   If (nvl(x_asset_hierarchy_purpose_id,0) <> 0) then
     Begin
        select 1 into dummy
        from fa_asset_hierarchy_purpose
        where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id;
     Exception
        when no_data_found then
          raise INVALID_PURPOSE_ID;
          -- x_err_code := 'CUA_INVALID_PURPOSE';
     End;
   else
     open C_PURPOSE;
     fetch C_PURPOSE into purpose_rec;
     if(C_PURPOSE%FOUND) then
        x_asset_hierarchy_purpose_id := purpose_rec.asset_hierarchy_purpose_id;
        if(x_calling_module = 'A'
       AND purpose_rec.mandatory_asset_flag = 'Y'
       AND nvl(x_parent_hierarchy_id,0) = 0) then
       close C_PURPOSE;
           raise PARENT_MANDATORY;
        end if;
     end if;
     close C_PURPOSE;
   end if;

   --Validate Parent node
   if (nvl(x_parent_hierarchy_id,0) <> 0 ) then
      x_err_stage := 'Validating Parent Node';
      open C_PARENT;
      fetch C_PARENT into v_book_type_code;
      if C_PARENT%NOTFOUND then
         raise INVALID_PARENT_NODE;
      else
         if v_book_type_code <> x_book_type_code then
           raise INVALID_PARENT_BOOK_TYPE;
         end if;
      end if;
      close C_PARENT;
   end if;
   --Validating Level number
   --check level number is a valid positive integer
   x_err_stage := 'Validating level is a positive integer';
   if( NOT validate_level_number(x_level_number, p_log_level_rec) ) then
     x_err_code := 'CUA_INVALID_LEVEL_NUMBER';
     return;
   end if;
   --Check level number is less than the permissible levels in purpose if purpose is given
   x_err_stage := 'Validating level with permissible levels';
   if(x_asset_hierarchy_purpose_id is not null ) then
     open C_PERMIT_LEVELS;
     fetch C_PERMIT_LEVELS into v_permit_levels;
     if(C_PERMIT_LEVELS%NOTFOUND) then
       x_err_code := 'CUA_INVALID_PURPOSE';
       close C_PERMIT_LEVELS;
       return;
     end if;
     close C_PERMIT_LEVELS;
     if(v_permit_levels <> 0 ) then
        if( x_level_number > v_permit_levels) then
          x_err_code := 'CUA_LEVEL_EXCEEDS_PERMIT';
          return;
        end if;
     end if;
   end if;
   --check level number is 0 for asset node
   x_err_stage := 'Validating level number for the node';
   if((x_calling_module = 'A' AND x_level_number <> 0 )
      OR(x_calling_module = 'N' AND x_level_number = 0 )   ) then
      x_err_code := 'CUA_INVALID_ASSET_LEVEL';
      return;
   end if;
   -- check parent level is 1 greater than the node level
   x_err_stage := 'Validating parent is one level higher to current node';
   if(nvl(x_parent_hierarchy_id,0) <> 0 ) then
     open C_PARENT_LEVEL;
     fetch C_PARENT_LEVEL into v_parent_level;
     if(C_PARENT_LEVEL%NOTFOUND) then
       x_err_code := 'CUA_INVALID_PARENT';
       close C_PARENT_LEVEL;
       return;
     end if;
     close C_PARENT_LEVEL;
     if (x_level_number <> v_parent_level - 1 ) then
       x_err_code := 'CUA_INVALID_NODE_PARENT_LEVEL';
       return;
     end if;
   end if;

   -- Validate Book Type
   x_err_stage := 'Validating Book Class';
   open C_BOOK;
   fetch C_BOOK into v_book_class;
   if C_BOOK%NOTFOUND then
     raise BOOK_TYPE_NOT_EXISTS;
   else
     if v_book_class <> 'CORPORATE' then
       raise INVALID_BOOK_TYPE;
     end if;
   end if;
   close C_BOOK;

   --Validate Rule Set
   if (nvl(x_hierarchy_rule_set_id,0) <> 0) then
      x_err_stage := 'Validating Rule Set';
      open C_RULE;
      fetch C_RULE into v_book_type_code;
      if C_RULE%NOTFOUND then
         raise INVALID_RULE_SET;
      else
         if (v_book_type_code <> x_book_type_code) then
            raise INVALID_RULE_BOOK;
         end if;
      end if;
      close C_RULE;
   end if;
   x_err_stack := l_old_err_stack;
 Exception
   when PARENT_MANDATORY then
     x_err_code := 'CUA_PARENT_MANDATORY';
   when INVALID_PURPOSE_ID then
     x_err_code := 'CUA_INVALID_PURPOSE';
   when PURPOSE_NOT_EXISTS then
     x_err_code := 'CUA_PURPOSE_NOT_EXISTS';
   when BOOK_TYPE_NOT_EXISTS then
     x_err_code := 'CUA_BOOK_TYPE_NOT_EXISTS';
     close C_BOOK;
   when INVALID_BOOK_TYPE then
     x_err_code := 'CUA_INVALID_BOOK_TYPE';
     close C_BOOK;
   when INVALID_PARENT_NODE then
     x_err_code := 'CUA_INVALID_PARENT_NODE';
     close C_PARENT;
   when INVALID_PARENT_BOOK_TYPE then
     x_err_code := 'CUA_INVALID_PARENT_BOOK_TYPE';
     close C_PARENT;
   when INVALID_RULE_SET then
     x_err_code := 'CUA_INVALID_RULE_SET';
     close C_RULE;
   when INVALID_RULE_BOOK then
     x_err_code := 'CUA_INVALID_PARENT_BOOK_TYPE';
     close C_RULE;
   when others then
     x_err_code := SQLCODE;
     if C_BOOK%ISOPEN then
        close C_BOOK;
     end if;
     if C_PARENT%ISOPEN then
        close C_PARENT;
     end if;
     if C_PURPOSE%ISOPEN then
        close C_PURPOSE;
     end if;
     if C_RULE%ISOPEN then
        close C_RULE;
     end if;

 End Validate_node;

 --Procedure to create node along with the attributes
procedure create_node_with_attributes(
 -- Arguments required for Public APIs
  x_err_code                    in out nocopy varchar2
, x_err_stage                   in out nocopy Varchar2
, x_err_stack                   in out nocopy varchar2
  -- Arguments for Node Creation
, x_asset_hierarchy_purpose_id  in     NUMBER
, x_asset_hierarchy_id          in out nocopy NUMBER
, x_name                        in     VARCHAR2 default null
, x_level_number                in NUMBER
, x_hierarchy_rule_set_id       in NUMBER  default null
, X_CREATION_DATE               in DATE    default trunc(sysdate)
, X_CREATED_BY                  in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_DATE            in DATE    default trunc(sysdate)
, X_LAST_UPDATED_BY             in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_LOGIN           in NUMBER  := FND_GLOBAL.USER_ID
, x_description                 in VARCHAR2 default null
, x_parent_hierarchy_id         in NUMBER  default null
, x_lowest_level_flag           in NUMBER  default null
, x_depreciation_start_date     in date default null
, x_asset_id                    in number   default null
, X_ATTRIBUTE_CATEGORY          in VARCHAR2 default null
, X_ATTRIBUTE1                  in VARCHAR2 default null
, X_ATTRIBUTE2                  in VARCHAR2 default null
, X_ATTRIBUTE3                  in VARCHAR2 default null
, X_ATTRIBUTE4                  in VARCHAR2 default null
, X_ATTRIBUTE5                  in VARCHAR2 default null
, X_ATTRIBUTE6                  in VARCHAR2 default null
, X_ATTRIBUTE7                  in VARCHAR2 default null
, X_ATTRIBUTE8                  in VARCHAR2 default null
, X_ATTRIBUTE9                  in VARCHAR2 default null
, X_ATTRIBUTE10                 in VARCHAR2 default null
, X_ATTRIBUTE11                 in VARCHAR2 default null
, X_ATTRIBUTE12                 in VARCHAR2 default null
, X_ATTRIBUTE13                 in VARCHAR2 default null
, X_ATTRIBUTE14                 in VARCHAR2 default null
, X_ATTRIBUTE15                 in VARCHAR2 default null
--Parameters for Node Attributes
,x_attribute_book_type_code     in varchar2 default null
,x_asset_category_id            in number default null
,x_lease_id                     in NUMBER default null
,x_asset_key_ccid               in number default null
,x_serial_number                in varchar2 default null
,x_life_end_date                in date default null
,x_distribution_tab             in FA_CUA_HIERARCHY_PKG.distribution_tabtype default FA_CUA_HIERARCHY_PKG.distribution_tab
,p_log_level_rec       IN     fa_api_types.log_level_rec_type)
is
l_old_err_stack   varchar2(640);
l_rowid     varchar2(240) default null;
l_distribution_id  number default null;
I BINARY_INTEGER;
l_dist_set_id      number default null;
Begin
  --Call the crete_node API to create the Node first
l_old_err_stack := x_err_stack;
x_err_code := '0';
x_err_stage := 'Calling CREATE_NODE';
FA_CUA_HIERARCHY_PKG.create_node(
  x_err_code
, x_err_stage
, x_err_stack
, x_asset_hierarchy_purpose_id
, x_asset_hierarchy_id
, x_name
, x_level_number
, x_hierarchy_rule_set_id
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, x_description
, x_parent_hierarchy_id
, x_lowest_level_flag
, x_depreciation_start_date
, x_asset_id
, X_ATTRIBUTE_CATEGORY
, X_ATTRIBUTE1
, X_ATTRIBUTE2
, X_ATTRIBUTE3
, X_ATTRIBUTE4
, X_ATTRIBUTE5
, X_ATTRIBUTE6
, X_ATTRIBUTE7
, X_ATTRIBUTE8
, X_ATTRIBUTE9
, X_ATTRIBUTE10
, X_ATTRIBUTE11
, X_ATTRIBUTE12
, X_ATTRIBUTE13
, X_ATTRIBUTE14
, X_ATTRIBUTE15
  , p_log_level_rec => p_log_level_rec);

  if(x_err_code <> '0' ) then
    rollback work;
    return;
  end if;
  /** Validate and create the distribution set if distribution
      table is passed                                       **/
      if(nvl(x_asset_id,0) = 0
        AND x_attribute_book_type_code is not null
        AND x_distribution_tab.count > 0 ) then
         FA_CUA_HIERARCHY_PKG.create_distribution_set
                       ( l_dist_set_id
                        ,x_attribute_book_type_code
                        ,x_distribution_tab
                        ,x_err_code
                        ,x_err_stage
                        ,x_err_stack    , p_log_level_rec => p_log_level_rec);
      end if;
      if(x_err_code <> '0' ) then
         rollback work;
         return;
      end if;
  /** Call the Validate Attributes and create attributes process
      only if the Node is a Non Asset Node and the Attribute Book
      and one of the other attribute is given                 **/
  if (nvl(x_asset_id,0) = 0
     AND x_attribute_book_type_code is not null
     AND (   x_asset_category_id is not null
          OR x_lease_id is not null
          OR x_asset_key_ccid is not null
          OR x_serial_number is not null
          OR x_life_end_date is not null
          OR l_dist_set_id is not null
          )
    ) then
    x_err_stage := 'Calling Validate_node_attributes';
    FA_CUA_HIERARCHY_PKG.validate_node_attributes
          (x_asset_hierarchy_purpose_id
          ,x_asset_hierarchy_id
          ,x_level_number
          ,x_attribute_book_type_code
          ,x_asset_category_id
          ,x_lease_id
          ,x_asset_key_ccid
          ,x_serial_number
          ,x_life_end_date
          ,l_dist_set_id
          ,x_err_code
          ,x_err_stage
          ,x_err_stack  , p_log_level_rec => p_log_level_rec);
    end if;
    if(x_err_code <> '0') then
        rollback work;
        return;
     else
        x_err_stage := 'Inserting into FA_ASSET_HIERARCHY_VALES table';
        if (x_attribute_book_type_code is not null
             AND (   x_asset_category_id is not null
                  OR x_lease_id is not null
                  OR x_asset_key_ccid is not null
                  OR x_serial_number is not null
                  OR x_life_end_date is not null
                  OR l_dist_set_id is not null)
            ) then
            --If corporate Book insert all values else insert only life end date
              FA_CUA_HIERARCHY_VALUES_PKG.Insert_row (
               l_rowid
             , x_asset_hierarchy_id
             , x_attribute_book_type_code
             , x_asset_category_id
             , x_lease_id
             , x_asset_key_ccid
             , x_serial_number
             , x_life_end_date
             , l_dist_set_id
             , X_CREATION_DATE
             , X_CREATED_BY
             , X_LAST_UPDATE_DATE
             , X_LAST_UPDATED_BY
             , X_LAST_UPDATE_LOGIN  , p_log_level_rec => p_log_level_rec);
      end if;
      /** Moved to Create_dist_set procedure  **
      x_err_stage := 'Inserting into FA_HIERARCHY_DISTRIBUTIONS table';
      l_rowid := null;
      --dbms_output.put_line('Before Inserting Distributions');
      --dbms_output.put_line('count:'||to_char(x_distribution_tab.count));
      if( x_distribution_tab.count > 0 ) then
         FOR I in 1..x_distribution_tab.count LOOP
           l_distribution_id := null;
           FA_CUA_HR_DISTRIBUTION_PKG.Insert_row (
               l_rowid
             , l_distribution_id
             , x_asset_hierarchy_purpose_id
             , x_asset_hierarchy_id
             , x_attribute_book_type_code
             , x_distribution_tab(I).distribution_line_percentage
             , x_distribution_tab(I).code_combination_id
             , x_distribution_tab(I).location_id
             , x_distribution_tab(I).assigned_to
             , X_CREATION_DATE
             , X_CREATED_BY
             , X_LAST_UPDATE_DATE
             , X_LAST_UPDATED_BY
             , X_LAST_UPDATE_LOGIN   );
           --dbms_output.put_line('Distribution ID:'||to_char(l_distribution_id));
          END LOOP;
      end if;
      ****/
  end if;
  x_err_stack := l_old_err_stack;
Exception
  when others then
     x_err_code := sqlerrm;
End create_node_with_attributes;

 procedure create_node(
  -- Arguments required for Public APIs
  x_err_code            in out nocopy varchar2
, x_err_stage           in out nocopy Varchar2
, x_err_stack           in out nocopy varchar2
  -- Arguments for Node Creation
, x_asset_hierarchy_purpose_id  in     NUMBER
, x_asset_hierarchy_id      in out nocopy NUMBER
, x_name                    in     VARCHAR2 default null
, x_level_number            in NUMBER
, x_hierarchy_rule_set_id   in NUMBER  default null
, X_CREATION_DATE           in DATE    default trunc(sysdate)
, X_CREATED_BY              in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_DATE        in DATE    default trunc(sysdate)
, X_LAST_UPDATED_BY         in NUMBER  := FND_GLOBAL.USER_ID
, X_LAST_UPDATE_LOGIN       in NUMBER  := FND_GLOBAL.USER_ID
, x_description             in VARCHAR2 default null
, x_parent_hierarchy_id     in NUMBER  default null
, x_lowest_level_flag       in NUMBER  default null
, x_depreciation_start_date in date default null
, x_asset_id                in number   default null
, X_ATTRIBUTE_CATEGORY      in VARCHAR2 default null
, X_ATTRIBUTE1          in VARCHAR2 default null
, X_ATTRIBUTE2          in VARCHAR2 default null
, X_ATTRIBUTE3          in VARCHAR2 default null
, X_ATTRIBUTE4          in VARCHAR2 default null
, X_ATTRIBUTE5          in VARCHAR2 default null
, X_ATTRIBUTE6          in VARCHAR2 default null
, X_ATTRIBUTE7          in VARCHAR2 default null
, X_ATTRIBUTE8          in VARCHAR2 default null
, X_ATTRIBUTE9          in VARCHAR2 default null
, X_ATTRIBUTE10         in VARCHAR2 default null
, X_ATTRIBUTE11         in VARCHAR2 default null
, X_ATTRIBUTE12         in VARCHAR2 default null
, X_ATTRIBUTE13         in VARCHAR2 default null
, X_ATTRIBUTE14         in VARCHAR2 default null
, X_ATTRIBUTE15         in VARCHAR2 default null
,p_log_level_rec       IN     fa_api_types.log_level_rec_type)
is
Cursor C_PURPOSE_BOOK is select book_type_code
                         from FA_ASSET_HIERARCHY_PURPOSE
                         where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id;

CURSOR C_NAME1 is SELECT ASSET_HIERARCHY_ID
                  FROM   FA_ASSET_HIERARCHY
                  WHERE  NAME = x_name
                  AND    NVL (ASSET_ID, 0) = 0
                  AND    ASSET_HIERARCHY_PURPOSE_ID = x_asset_hierarchy_purpose_id;

CURSOR C_NAME2 is SELECT ASSET_HIERARCHY_ID
                  FROM   FA_ASSET_HIERARCHY
                  WHERE  NAME = x_name
                  AND    ASSET_ID = x_asset_id
                  AND    ASSET_HIERARCHY_PURPOSE_ID = x_asset_hierarchy_purpose_id;

Cursor C_PERMIT_LEVELS is select nvl(permissible_levels,0)
                          from FA_ASSET_HIERARCHY_PURPOSE
                          where asset_hierarchy_purpose_id = x_asset_hierarchy_purpose_id;
 v_permit_levels  FA_ASSET_HIERARCHY_PURPOSE.permissible_levels%TYPE;
  l_rowid        varchar2(30);
  l_old_err_stack    varchar2(240);
  l_book_type_code varchar2(30);
  l_asset_hierarchy_purpose_id number;
  l_calling_module   varchar2(1);
  INVALID_PURPOSE EXCEPTION;
Begin
  x_err_code := '0';
  l_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'CREATE_NODE';
  --Validating the node already exists with this name and if so returns the ID
  x_err_stage := 'Check for the existance of the node';
  if x_name is not null then
     -- Fix for Bug #1064659.  Check x_asset_id for performance considerations.
     if (x_asset_id is null) or (x_asset_id = 0) then
        open C_NAME1;
        fetch C_NAME1 into x_asset_hierarchy_id;
        if C_NAME1%FOUND then
           close C_NAME1;
           return;
        end if;
        close C_NAME1;
     else
        open C_NAME2;
        fetch C_NAME2 into x_asset_hierarchy_id;
        if C_NAME2%FOUND then
           close C_NAME2;
           return;
        end if;
        close C_NAME2;
     end if;
  end if;
  --Check whether batch for this batch is un applied for asset nodes,if so return
  x_err_stage := 'Checking for Pending Parent Batches';
  if(nvl(x_asset_id,0) <> 0 ) then
    open C_PURPOSE_BOOK;
    fetch C_PURPOSE_BOOK into l_book_type_code;
    close C_PURPOSE_BOOK;

     -- msiddiqu bugfix 1613852
    if fa_cua_hr_retirements_pkg.check_pending_batch
                            ( x_calling_function => 'MASS_ADDITION',
                              x_book_type_code  => l_book_type_code,
                              x_event_code      => 'ADDITION',
                              x_asset_id        => x_asset_id,
                              x_node_id         => x_parent_hierarchy_id,
                              x_category_id     => null,
                              x_attribute       => null,
                              x_conc_request_id => null,
                              x_status          => x_err_code , p_log_level_rec => p_log_level_rec) then
/** commented by msiddiqu for bugfix 1613852
    if(fa_cua_hr_retirements_pkg.check_pending_batch('ADDITION'
					     ,l_book_type_code
					     ,x_asset_id
					     ,x_parent_hierarchy_id)
      ) then  **/
      x_err_code := 'CUA_PENDING_PARENT_BATCH';
      return;
    end if;
  end if;
  /** Validate the level number is less than the permissible levels.
  Though the check is performed in validate node, it is repeated here because
  this check may not be performed at Validate node level if the
  purpose ID is not known. **/
  x_err_stage := 'Validating Level Number with permit level - Create Node';
  open C_PERMIT_LEVELS;
  fetch C_PERMIT_LEVELS into v_permit_levels;
  if(C_PERMIT_LEVELS%NOTFOUND) then
     x_err_code := 'CUA_INVALID_PURPOSE';
     close C_PERMIT_LEVELS;
     return;
  end if;
  close C_PERMIT_LEVELS;
  if(v_permit_levels <> 0 ) then
     if( x_level_number > v_permit_levels) then
         x_err_code := 'CUA_LEVEL_EXCEEDS_PERMIT';
         return;
      end if;
  end if;
  --Validating depreciation start date is given if DPIS is Mandatory
  x_err_stage := 'Validating Date Placed in Service is Mandatory';
  if (    x_level_number <> 0
      AND x_depreciation_start_date is null
      AND is_attribute_mandatory(x_asset_hierarchy_purpose_id
                                ,x_level_number
                                ,'DPIS'
                                ,p_log_level_rec)
     ) then
     x_err_code := 'CUA_DPIS_MANDATORY';
     return;
  end if;
  -- Check Node name is not null for Asset Node
   x_err_stage := 'Checking for Mandatory name for Asset Node';
   if (x_level_number = 0 AND x_name is null) then
       x_err_code := 'CUA_NAME_MANDATORY_ASSET';
       return;
   end if;
  x_err_stage := 'Getting the book from purpose';
  open C_PURPOSE_BOOK;
  fetch C_PURPOSE_BOOK into l_book_type_code;
  if C_PURPOSE_BOOK%NOTFOUND then
     close C_PURPOSE_BOOK;
     raise INVALID_PURPOSE;
  end if;
  close C_PURPOSE_BOOK;
  if(nvl(x_asset_id,0) = 0) then
    l_calling_module := 'N';
  else
    l_calling_module := 'A';
  end if;
  x_err_stage := 'Validating Node';
  FA_CUA_HIERARCHY_PKG.Validate_node(
              l_calling_module
            , l_asset_hierarchy_purpose_id
            , l_book_type_code
            , x_name
            , x_level_number
            , x_parent_hierarchy_id
            , x_hierarchy_rule_set_id
            , x_err_code
            , x_err_stage
            , x_err_stack, p_log_level_rec => p_log_level_rec);
   if (x_err_code = '0') then
      x_err_stage := 'Inserting Node';
    --  x_err_stack := x_err_stack ||'->'||'INASERT_NODE';
      FA_CUA_HIERARCHY_PKG.Insert_row (
               l_rowid
             , x_asset_hierarchy_purpose_id
             , x_asset_hierarchy_id
             , x_name
             , x_level_number
             , x_hierarchy_rule_set_id
             , X_CREATION_DATE
             , X_CREATED_BY
             , X_LAST_UPDATE_DATE
             , X_LAST_UPDATED_BY
             , X_LAST_UPDATE_LOGIN
             , x_description
             , x_parent_hierarchy_id
             , x_lowest_level_flag
             , x_depreciation_start_date
             , x_asset_id
             , X_ATTRIBUTE_CATEGORY
             , X_ATTRIBUTE1
             , X_ATTRIBUTE2
             , X_ATTRIBUTE3
             , X_ATTRIBUTE4
             , X_ATTRIBUTE5
             , X_ATTRIBUTE6
             , X_ATTRIBUTE7
             , X_ATTRIBUTE8
             , X_ATTRIBUTE9
             , X_ATTRIBUTE10
             , X_ATTRIBUTE11
             , X_ATTRIBUTE12
             , X_ATTRIBUTE13
             , X_ATTRIBUTE14
             , X_ATTRIBUTE15 , p_log_level_rec => p_log_level_rec);
    x_err_stack := l_old_err_stack;
    end if;

exception
  when INVALID_PURPOSE then
   x_err_stage :='Unable to get Purpose Book';
   x_err_code := 'CUA_INVALID_PURPOSE';
  when no_data_found then
    x_err_stage := 'CREATE_NODE_NO_DATA';
    x_err_code := SQLCODE;
  when others then
    x_err_stage := 'CREATE_NODE_WHEN_OTHERS';
    x_err_code := SQLCODE;
end create_node;


procedure LOCK_ROW (
  x_asset_hierarchy_purpose_id  in NUMBER
, x_asset_hierarchy_id      in NUMBER
, x_name                    in VARCHAR2
, x_level_number            in number
, x_hierarchy_rule_set_id   in NUMBER
, x_description             in VARCHAR2
, x_parent_hierarchy_id     in NUMBER
, x_lowest_level_flag       in NUMBER
, x_depreciation_start_date in date
, x_asset_id                in number
, X_ATTRIBUTE_CATEGORY      in VARCHAR2
, X_ATTRIBUTE1          in VARCHAR2
, X_ATTRIBUTE2          in VARCHAR2
, X_ATTRIBUTE3          in VARCHAR2
, X_ATTRIBUTE4          in VARCHAR2
, X_ATTRIBUTE5          in VARCHAR2
, X_ATTRIBUTE6          in VARCHAR2
, X_ATTRIBUTE7          in VARCHAR2
, X_ATTRIBUTE8          in VARCHAR2
, X_ATTRIBUTE9          in VARCHAR2
, X_ATTRIBUTE10         in VARCHAR2
, X_ATTRIBUTE11         in VARCHAR2
, X_ATTRIBUTE12         in VARCHAR2
, X_ATTRIBUTE13         in VARCHAR2
, X_ATTRIBUTE14         in VARCHAR2
, X_ATTRIBUTE15         in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) is
  cursor c1 is select
  name
, level_number
, hierarchy_rule_set_id
, description
, parent_hierarchy_id
, lowest_level_flag
, depreciation_start_date
, asset_id
, ATTRIBUTE_CATEGORY
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
    from FA_ASSET_HIERARCHY
    where asset_hierarchy_id = x_asset_hierarchy_id
    and nvl(asset_hierarchy_purpose_id,1) = nvl(x_asset_hierarchy_purpose_id,1)
    for update of asset_hierarchy_id nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
if( nvl(x_asset_id,0) = 0 ) then
  if ( (tlinfo.NAME = X_NAME)
      AND (tlinfo.level_number = x_level_number)
      AND ((tlinfo.hierarchy_rule_set_id = x_hierarchy_rule_set_id)
           OR ((tlinfo.hierarchy_rule_set_id is null)
        AND (x_hierarchy_rule_set_id is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.PARENT_HIERARCHY_ID = X_PARENT_HIERARCHY_ID)
           OR ((tlinfo.PARENT_HIERARCHY_ID is null)
               AND (X_PARENT_HIERARCHY_ID is null)))
      AND ((tlinfo.LOWEST_LEVEL_FLAG = X_LOWEST_LEVEL_FLAG)
           OR ((tlinfo.LOWEST_LEVEL_FLAG is null)
               AND (X_LOWEST_LEVEL_FLAG is null)))
      AND ((tlinfo.DEPRECIATION_START_DATE = X_DEPRECIATION_START_DATE)
           OR ((tlinfo.DEPRECIATION_START_DATE is null)
               AND (X_DEPRECIATION_START_DATE is null)))
      AND ((tlinfo.ASSET_ID = X_ASSET_ID)
           OR ((tlinfo.ASSET_ID is null)
               AND (X_ASSET_ID is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
    AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
    AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
    AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
    AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
    AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
else
  if ( (tlinfo.NAME = X_NAME)
      AND (tlinfo.level_number = x_level_number)
      AND ((tlinfo.hierarchy_rule_set_id = x_hierarchy_rule_set_id)
           OR ((tlinfo.hierarchy_rule_set_id is null)
        AND (x_hierarchy_rule_set_id is null)))
      --AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
      --     OR ((tlinfo.DESCRIPTION is null)
      --         AND (X_DESCRIPTION is null)))
      AND ((tlinfo.PARENT_HIERARCHY_ID = X_PARENT_HIERARCHY_ID)
           OR ((tlinfo.PARENT_HIERARCHY_ID is null)
               AND (X_PARENT_HIERARCHY_ID is null)))
      AND ((tlinfo.LOWEST_LEVEL_FLAG = X_LOWEST_LEVEL_FLAG)
           OR ((tlinfo.LOWEST_LEVEL_FLAG is null)
               AND (X_LOWEST_LEVEL_FLAG is null)))
    --  AND ((tlinfo.DEPRECIATION_START_DATE = X_DEPRECIATION_START_DATE)
    --       OR ((tlinfo.DEPRECIATION_START_DATE is null)
    --           AND (X_DEPRECIATION_START_DATE is null)))
      AND ((tlinfo.ASSET_ID = X_ASSET_ID)
           OR ((tlinfo.ASSET_ID is null)
               AND (X_ASSET_ID is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
    AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
    AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
    AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
    AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
    AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  x_asset_hierarchy_purpose_id  in NUMBER
, x_asset_hierarchy_id      in NUMBER
, x_name                    in VARCHAR2
, x_level_number            in NUMBER
, x_hierarchy_rule_set_id       in NUMBER
, X_LAST_UPDATE_DATE        in DATE
, X_LAST_UPDATED_BY     in NUMBER
, X_LAST_UPDATE_LOGIN       in NUMBER
, x_description             in VARCHAR2
, x_parent_hierarchy_id     in NUMBER
, x_lowest_level_flag       in NUMBER
, X_DEPRECIATION_START_DATE in DATE
, x_asset_id            in number
, X_ATTRIBUTE_CATEGORY      in VARCHAR2
, X_ATTRIBUTE1          in VARCHAR2
, X_ATTRIBUTE2          in VARCHAR2
, X_ATTRIBUTE3          in VARCHAR2
, X_ATTRIBUTE4          in VARCHAR2
, X_ATTRIBUTE5          in VARCHAR2
, X_ATTRIBUTE6          in VARCHAR2
, X_ATTRIBUTE7          in VARCHAR2
, X_ATTRIBUTE8          in VARCHAR2
, X_ATTRIBUTE9          in VARCHAR2
, X_ATTRIBUTE10         in VARCHAR2
, X_ATTRIBUTE11         in VARCHAR2
, X_ATTRIBUTE12         in VARCHAR2
, X_ATTRIBUTE13         in VARCHAR2
, X_ATTRIBUTE14         in VARCHAR2
, X_ATTRIBUTE15         in VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)is
 begin
   update FA_ASSET_HIERARCHY set
        name = x_name,
    --level_number = x_level_number, --Level number is Non Updateable
    hierarchy_rule_set_id  = x_hierarchy_rule_set_id,
    description = x_description,
    parent_hierarchy_id = x_parent_hierarchy_id,
    lowest_level_flag = x_lowest_level_flag,
    depreciation_start_date = x_depreciation_start_date,
    asset_id = x_asset_id,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 = X_ATTRIBUTE1,
        ATTRIBUTE2 = X_ATTRIBUTE2,
        ATTRIBUTE3 = X_ATTRIBUTE3,
        ATTRIBUTE4 = X_ATTRIBUTE4,
        ATTRIBUTE5 = X_ATTRIBUTE5,
        ATTRIBUTE6 = X_ATTRIBUTE6,
        ATTRIBUTE7 = X_ATTRIBUTE7,
        ATTRIBUTE8 = X_ATTRIBUTE8,
        ATTRIBUTE9 = X_ATTRIBUTE9,
        ATTRIBUTE10 = X_ATTRIBUTE10,
        ATTRIBUTE11 = X_ATTRIBUTE11,
        ATTRIBUTE12 = X_ATTRIBUTE12,
        ATTRIBUTE13 = X_ATTRIBUTE13,
        ATTRIBUTE14 = X_ATTRIBUTE14,
        ATTRIBUTE15 = X_ATTRIBUTE15,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where asset_hierarchy_id= X_asset_hierarchy_id
  and  nvl(asset_hierarchy_purpose_id,1) = nvl(x_asset_hierarchy_purpose_id,1);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  x_asset_hierarchy_purpose_id in number
, X_asset_hierarchy_id in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) is
begin
  delete from FA_ASSET_HIERARCHY
  where asset_hierarchy_id = X_asset_hierarchy_id
  and nvl(asset_hierarchy_purpose_id,1) = nvl(x_asset_hierarchy_purpose_id,1);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

function is_non_asset_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return boolean
is
  v_asset_id number;
  cursor C is
   select nvl(asset_id,0) from FA_ASSET_HIERARCHY
   where asset_hierarchy_id = x_asset_hierarchy_id;
Begin
  open C;
  fetch C into v_asset_id;
  close C;
  if (v_asset_id = 0) then
    return (TRUE);
  else
    return (FALSE);
  end if;
end is_non_asset_node;

--Function to check the particular attribute is mandatory
Function is_attribute_mandatory(x_hierarchy_purpose_id in number
                                ,x_level_number       in number
                                ,x_attribute_name     in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return Boolean
is
Cursor C is select 1
            from fa_hierarchy_controls
            where asset_hierarchy_purpose_id = x_hierarchy_purpose_id
            and   level_number = x_level_number
            and   nvl(decode(x_attribute_name,'CATEGORY',category_mandatory_flag
                                             ,'LEASE',lease_mandatory_flag
                                             ,'ASSET_KEY',asset_key_mandatory_flag
                                             ,'SERIAL_NUMBER',serial_number_mandatory_flag
                                             ,'DISTRIBUTION',distribution_mandatory_flag
                                             ,'LED',life_end_date_mandatory_flag
                                             ,'DPIS',dpis_mandatory_flag
                             ),'N') = 'Y';
dummy  number;
Begin
    open C;
    fetch C into dummy;
    if C%NOTFOUND then
      close C;
      return FALSE;
    end if;
    close C;
    return TRUE;
End is_attribute_mandatory;

 /* Check for the lowest level non asset node with no Non asset nodes attached */
Function check_lowest_level_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
dummy   number;
Begin
  select 1 into dummy from fa_asset_hierarchy
    where asset_hierarchy_id = x_asset_hierarchy_id
    and nvl(asset_id,0) = 0
    and not exists (Select 1
            from fa_asset_hierarchy a
            where nvl(a.asset_id,0) = 0
            and a.parent_hierarchy_id = x_asset_hierarchy_id);
  return(TRUE);
exception
  when no_data_found then
        return(FALSE);
end check_lowest_level_node;

Function check_asset_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return Boolean
is
cursor C is select nvl(asset_id,0)
        from fa_asset_hierarchy
        where asset_hierarchy_id = x_asset_hierarchy_id;
v_asset_id number;
dummy   number;
Begin
  open C;
  fetch C into v_asset_id;
  close C;
  if (v_asset_id <> 0) then
    return(TRUE);
  else
    return (FALSE);
  end if;
end check_asset_node;

Function Check_asset_tied_node(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null)
return BOOLEAN
is
dummy   number;
Begin
 select 1 into dummy
 from dual
 where exists (Select 1 from fa_asset_hierarchy
        where parent_hierarchy_id = x_asset_hierarchy_id
        and  nvl(asset_id,0) <> 0);
 return (TRUE);
Exception
 when no_data_found then
 return (FALSE);
End check_asset_tied_node;

Function is_child_exists(x_asset_hierarchy_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)
return BOOLEAN
is
dummy  number;
begin
 select 1 into dummy from dual
 where exists(select 1 from fa_asset_hierarchy
        where parent_hierarchy_id = x_asset_hierarchy_id);
 return(TRUE);
Exception
  when no_data_found then
   return(FALSE);
end is_child_exists;

/* Function to check assets are attached to the tree branch */
  Function is_assets_attached_node(x_node_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return boolean
  is
  dummy number;
  Begin
     select 1 into dummy from dual
     where exists ( select asset_hierarchy_id
                    from fa_asset_hierarchy
                    where nvl(asset_id,0) <> 0
                    start with asset_hierarchy_id = x_node_id
                    connect by prior asset_hierarchy_id = parent_hierarchy_id);
     return(TRUE);
  Exception
     when no_data_found then
        return(FALSE);
  End is_assets_attached_node;

Function is_valid_line_percent(x_line_percent in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return boolean
is
Begin
  if(nvl(x_line_percent,0) >=0 and nvl(x_line_percent,0) <=100) then
    return TRUE;
  else
    return FALSE;
  end if;
End is_valid_line_percent;

Procedure wrapper_validate_node (p_log_level_rec       IN
fa_api_types.log_level_rec_type ) is
begin
      validate_node(x_asset_hierarchy_purpose_id => FA_CUA_HIERARCHY_PKG.g_asset_hierarchy_purpose_id,
                        x_book_type_code => FA_CUA_HIERARCHY_PKG.g_book_type_code,
                        x_name => FA_CUA_HIERARCHY_PKG.g_name,
                        x_level_number => 0,
                        x_parent_hierarchy_id => FA_CUA_HIERARCHY_PKG.g_parent_hierarchy_id,
                        x_err_code => FA_CUA_HIERARCHY_PKG.g_err_code,
                        x_err_stage => FA_CUA_HIERARCHY_PKG.g_err_stage,
                        x_err_stack => FA_CUA_HIERARCHY_PKG.g_err_stack, p_log_level_rec => p_log_level_rec);
end wrapper_validate_node;


end FA_CUA_HIERARCHY_PKG ;

/
